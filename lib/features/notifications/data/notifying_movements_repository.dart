import 'dart:async';

import '../../balances/data/movements_repository.dart';
import '../../balances/domain/ledger_movement.dart';
import '../domain/push_event.dart';
import 'notification_dispatcher.dart';

/// [MovementsRepository] that, after each successful write, tells the
/// other party (through [NotificationDispatcher]). Reads go straight
/// through. The notification is not awaited: the write is already done.
class NotifyingMovementsRepository implements MovementsRepository {
  NotifyingMovementsRepository(this._inner, this._dispatcher);

  final MovementsRepository _inner;
  final NotificationDispatcher _dispatcher;

  void _notify(PushEvent event) => unawaited(_dispatcher.notify(event));

  @override
  Stream<List<LedgerMovement>> watchGroup(String groupId) =>
      _inner.watchGroup(groupId);

  @override
  Stream<MovementPage> watchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
  }) => _inner.watchPairHistory(
    me: me,
    other: other,
    groupId: groupId,
    limit: limit,
  );

  @override
  Future<MovementPage> fetchPairHistory({
    required String me,
    required String other,
    String? groupId,
    required int limit,
    required Object after,
  }) => _inner.fetchPairHistory(
    me: me,
    other: other,
    groupId: groupId,
    limit: limit,
    after: after,
  );

  @override
  Stream<List<LedgerMovement>> watchRecent({
    required String groupId,
    required String me,
    required int limit,
  }) => _inner.watchRecent(groupId: groupId, me: me, limit: limit);

  @override
  Future<LedgerMovement?> fetchMovement({
    required String groupId,
    required String movementId,
  }) => _inner.fetchMovement(groupId: groupId, movementId: movementId);

  @override
  Future<List<String>> registerPayments(List<LedgerMovement> payments) async {
    final ids = await _inner.registerPayments(payments);
    // One request per group: the Worker reads them under that group.
    final byGroup = <String, List<String>>{};
    for (var i = 0; i < ids.length && i < payments.length; i++) {
      byGroup.putIfAbsent(payments[i].groupId, () => []).add(ids[i]);
    }
    for (final MapEntry(key: groupId, value: groupIds) in byGroup.entries) {
      _notify(MovementEvent(MovementEventKind.created, groupId, groupIds));
    }
    return ids;
  }

  @override
  Future<String> registerDebt(LedgerMovement debt) async {
    final id = await _inner.registerDebt(debt);
    _notify(MovementEvent(MovementEventKind.created, debt.groupId, [id]));
    return id;
  }

  @override
  Future<void> reject({
    required LedgerMovement movement,
    required String uid,
    required RejectReason reason,
    String? note,
  }) async {
    await _inner.reject(
      movement: movement,
      uid: uid,
      reason: reason,
      note: note,
    );
    _notify(
      MovementEvent(MovementEventKind.rejected, movement.groupId, [
        movement.id,
      ]),
    );
  }

  @override
  Future<void> delete({
    required LedgerMovement movement,
    required String uid,
  }) async {
    await _inner.delete(movement: movement, uid: uid);
    _notify(
      MovementEvent(MovementEventKind.deleted, movement.groupId, [movement.id]),
    );
  }

  @override
  Future<void> markSeen({
    required LedgerMovement movement,
    required String uid,
  }) => _inner.markSeen(movement: movement, uid: uid);
}
