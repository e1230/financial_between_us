import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/firestore_collections.dart';
import '../../groups/data/group_mapper.dart' show AuditLogFields;
import '../domain/ledger_movement.dart';
import '../domain/movement_failure.dart';
import 'movement_mapper.dart';

/// A page of movements, newest first.
final class MovementPage {
  const MovementPage({
    required this.items,
    required this.cursor,
    required this.hasMore,
  });

  static const MovementPage empty = MovementPage(
    items: [],
    cursor: null,
    hasMore: false,
  );

  final List<LedgerMovement> items;

  /// Where the next page starts (opaque to everything but the repository);
  /// `null` when the page is empty.
  final Object? cursor;

  /// There may be older movements.
  final bool hasMore;
}

/// Debts and payments of the groups: the ledger every balance is computed
/// from. Every method throws a [MovementFailure] on error.
abstract interface class MovementsRepository {
  /// Live **active** movements of [groupId], in no particular order: what
  /// the balances need. Rejected and deleted ones only show up in the
  /// paged history.
  Stream<List<LedgerMovement>> watchGroup(String groupId);

  /// Live newest [limit] movements (any status) between [me] and [other],
  /// in [groupId] or, when `null`, in every group: the first page of a
  /// history.
  Stream<MovementPage> watchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
  });

  /// The [limit] movements of the same history older than [after].
  Future<MovementPage> fetchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
    required Object after,
  });

  /// Live newest [limit] movements (any status) of [groupId] where [me] is
  /// a party ("Últimos movimientos").
  Stream<List<LedgerMovement>> watchRecent({
    required String groupId,
    required String me,
    required int limit,
  });

  /// Saves the new [payments] together (a payment from "Todos los grupos"
  /// becomes one movement per group). Their ids are ignored; returns the
  /// new ids in the same order.
  Future<List<String>> registerPayments(List<LedgerMovement> payments);

  /// Saves the new [debt] (its id is ignored) and returns its id.
  Future<String> registerDebt(LedgerMovement debt);

  /// [uid], the recipient of [movement], rejects it.
  Future<void> reject({
    required LedgerMovement movement,
    required String uid,
    required RejectReason reason,
    String? note,
  });

  /// [uid], the author of [movement], deletes it (soft delete).
  Future<void> delete({required LedgerMovement movement, required String uid});

  /// [uid] opened [movement] (clears its "new" dot).
  Future<void> markSeen({
    required LedgerMovement movement,
    required String uid,
  });
}

// DECISIÓN: balances need every active movement of the group (the rules
// let any active member read them), so the group detail can tell whether a
// member is even with everybody. Rejected and deleted ones are not read for
// that; the histories are paged instead.
// TODO: move the computation to a Cloud Function that keeps
// `groups/{gid}/balances/{uidA_uidB}` if the volume grows (Blaze plan).
class FirestoreMovementsRepository implements MovementsRepository {
  FirestoreMovementsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _group(String groupId) =>
      _firestore.collection(FirestoreCollections.groups).doc(groupId);

  CollectionReference<Map<String, dynamic>> _movements(String groupId) =>
      _group(groupId).collection(FirestoreCollections.groupMovements);

  DocumentReference<Map<String, dynamic>> _newAuditEntry(String groupId) =>
      _group(groupId).collection(FirestoreCollections.groupAuditLog).doc();

  @override
  Stream<List<LedgerMovement>> watchGroup(String groupId) =>
      _movements(groupId)
          .where(MovementFields.status, isEqualTo: MovementStatus.active.wire)
          .snapshots()
          .map(
            (snapshot) => [
              for (final doc in snapshot.docs)
                ?MovementMapper.fromFirestore(groupId, doc.id, doc.data()),
            ],
          )
          .handleError((Object error, StackTrace stackTrace) {
            throw _map(error, stackTrace);
          });

  /// The history of [me] and [other]: in [groupId] (index `pairKey` +
  /// `date`) or across every group with a collection group query that the
  /// rules allow only on the user's own movements (index `participants` +
  /// `pairKey` + `date`).
  Query<Map<String, dynamic>> _pairQuery(
    String me,
    String other,
    String? groupId,
  ) {
    final key = pairKeyOf(me, other);
    final Query<Map<String, dynamic>> base = groupId == null
        ? _firestore
              .collectionGroup(FirestoreCollections.groupMovements)
              .where(MovementFields.participants, arrayContains: me)
        : _movements(groupId);
    return base
        .where(MovementFields.pairKey, isEqualTo: key)
        .orderBy(MovementFields.date, descending: true);
  }

  static MovementPage _page(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    int limit,
  ) {
    final docs = snapshot.docs;
    return MovementPage(
      items: [
        for (final doc in docs)
          ?MovementMapper.fromFirestore(
            doc.reference.parent.parent?.id ?? '',
            doc.id,
            doc.data(),
          ),
      ],
      cursor: docs.isEmpty ? null : docs.last,
      hasMore: docs.length >= limit,
    );
  }

  @override
  Stream<MovementPage> watchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
  }) => _pairQuery(me, other, groupId)
      .limit(limit)
      .snapshots()
      .map((snapshot) => _page(snapshot, limit))
      .handleError((Object error, StackTrace stackTrace) {
        throw _map(error, stackTrace);
      });

  @override
  Future<MovementPage> fetchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
    required Object after,
  }) => _guard(() async {
    if (after is! DocumentSnapshot) {
      throw ArgumentError.value(after, 'after', 'not a cursor of this query');
    }
    final snapshot = await _pairQuery(
      me,
      other,
      groupId,
    ).startAfterDocument(after).limit(limit).get();
    return _page(snapshot, limit);
  });

  @override
  Stream<List<LedgerMovement>> watchRecent({
    required String groupId,
    required String me,
    required int limit,
  }) =>
      _movements(groupId)
          .where(MovementFields.participants, arrayContains: me)
          .orderBy(MovementFields.date, descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => _page(snapshot, limit).items)
          .handleError((Object error, StackTrace stackTrace) {
            throw _map(error, stackTrace);
          });

  @override
  Future<List<String>> registerPayments(List<LedgerMovement> payments) =>
      _guard(() async {
        final batch = _firestore.batch();
        final ids = <String>[];
        for (final payment in payments) {
          ids.add(_addCreate(batch, payment));
        }
        await batch.commit();
        return ids;
      });

  @override
  Future<String> registerDebt(LedgerMovement debt) => _guard(() async {
    final batch = _firestore.batch();
    final id = _addCreate(batch, debt);
    await batch.commit();
    return id;
  });

  /// Adds the creation of [movement] and its audit entry to [batch].
  String _addCreate(WriteBatch batch, LedgerMovement movement) {
    final ref = _movements(movement.groupId).doc();
    batch
      ..set(ref, MovementMapper.create(movement))
      ..set(
        _newAuditEntry(movement.groupId),
        MovementMapper.auditEntry(
          action: AuditLogFields.actionCreate,
          movementId: ref.id,
          uid: movement.createdBy,
          after: MovementMapper.content(movement),
        ),
      );
    return ref.id;
  }

  @override
  Future<void> reject({
    required LedgerMovement movement,
    required String uid,
    required RejectReason reason,
    String? note,
  }) => _guard(() async {
    if (!movement.canReject(uid)) throw const MovementNotAllowed();
    final trimmed = note?.trim();
    final cleanNote = trimmed == null || trimmed.isEmpty ? null : trimmed;
    await (_firestore.batch()
          ..update(
            _movements(movement.groupId).doc(movement.id),
            MovementMapper.reject(uid: uid, reason: reason, note: cleanNote),
          )
          ..set(
            _newAuditEntry(movement.groupId),
            MovementMapper.auditEntry(
              action: AuditLogFields.actionReject,
              movementId: movement.id,
              uid: uid,
              before: {MovementFields.status: MovementStatus.active.wire},
              after: {
                MovementFields.status: MovementStatus.rejected.wire,
                MovementFields.rejectReason: reason.wire,
                MovementFields.rejectNote: cleanNote,
              },
            ),
          ))
        .commit();
  });

  @override
  Future<void> delete({
    required LedgerMovement movement,
    required String uid,
  }) => _guard(() async {
    if (!movement.canDelete(uid)) throw const MovementNotAllowed();
    await (_firestore.batch()
          ..update(
            _movements(movement.groupId).doc(movement.id),
            MovementMapper.softDelete(),
          )
          ..set(
            _newAuditEntry(movement.groupId),
            MovementMapper.auditEntry(
              action: AuditLogFields.actionDelete,
              movementId: movement.id,
              uid: uid,
              before: MovementMapper.content(movement),
            ),
          ))
        .commit();
  });

  @override
  Future<void> markSeen({
    required LedgerMovement movement,
    required String uid,
  }) => _guard(() async {
    if (movement.seenBy.contains(uid) || !movement.involves(uid)) return;
    await _movements(movement.groupId)
        .doc(movement.id)
        .update(MovementMapper.markSeen(uid));
  });

  /// Runs [action] and converts any error into a [MovementFailure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      throw _map(error, stackTrace);
    }
  }

  static MovementFailure _map(Object error, StackTrace stackTrace) {
    if (error is MovementFailure) return error;
    developer.log(
      'Movement request failed',
      name: 'fbu.movements',
      error: error,
      stackTrace: stackTrace,
    );
    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable' || 'deadline-exceeded' => const MovementNetworkFailure(),
        'permission-denied' || 'not-found' => const MovementNotAllowed(),
        _ => UnknownMovementFailure(error.code),
      };
    }
    return const UnknownMovementFailure();
  }
}
