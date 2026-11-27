import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/firestore_collections.dart';
import '../../groups/data/group_mapper.dart' show AuditLogFields;
import '../domain/ledger_movement.dart';
import '../domain/movement_failure.dart';
import 'movement_mapper.dart';

/// Debts and payments of the groups: the ledger every balance is computed
/// from. Every method throws a [MovementFailure] on error.
abstract interface class MovementsRepository {
  /// Live movements of [groupId] (any status), in no particular order.
  Stream<List<LedgerMovement>> watchGroup(String groupId);

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

// DECISIÓN: the app reads every movement of the group (the rules let any
// active member do it) instead of only the user's, so the group detail can
// tell whether a member is even with everybody and no composite index is
// needed. A group has at most 10 people and a few hundred movements.
// TODO: move the computation to a Cloud Function that keeps
// `groups/{gid}/balances/{uidA_uidB}` if the volume grows.
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
