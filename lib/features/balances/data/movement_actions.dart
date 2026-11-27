import '../domain/group_event.dart';
import '../domain/ledger_movement.dart';
import '../domain/payment_allocation.dart';
import 'movements_repository.dart';
import 'receipt_picker.dart';
import 'receipt_uploader.dart';

/// What the balances screens do with movements: upload the attached image
/// first (if it fails, nothing is saved) and then write.
class MovementActions {
  MovementActions({required this.repository, required this.uploader});

  final MovementsRepository repository;
  final ReceiptUploader uploader;

  /// [payerUid] paid [receiverUid] what [allocations] say; [me] is one of
  /// them. Allocations of different groups become one payment per group,
  /// with the same account, note, date and image. Returns their ids.
  Future<List<String>> registerPayment({
    required String me,
    required String payerUid,
    required String receiverUid,
    required List<Allocation> allocations,
    required DateTime date,
    AccountSnapshot? account,
    String? note,
    PickedReceipt? receipt,
  }) async {
    if (allocations.isEmpty) {
      throw ArgumentError.value(allocations, 'allocations', 'empty');
    }
    final byGroup = <String, List<Allocation>>{};
    for (final a in allocations) {
      byGroup.putIfAbsent(a.item.groupId, () => []).add(a);
    }
    final attachment = receipt == null
        ? null
        : await uploader.upload(receipt.path, groupId: byGroup.keys.first);
    return repository.registerPayments([
      for (final MapEntry(key: groupId, value: parts) in byGroup.entries)
        LedgerMovement(
          id: '',
          groupId: groupId,
          type: LedgerMovementType.payment,
          debtorUid: payerUid,
          creditorUid: receiverUid,
          amount: parts.fold(0, (sum, a) => sum + a.amount),
          appliedTo: [for (final a in parts) a.toApplication()],
          account: account,
          note: _clean(note),
          attachment: attachment,
          date: date,
          createdBy: me,
        ),
    ]);
  }

  /// [me] registers that [debtorUid] owes [creditorUid] [amount] in
  /// [groupId]: of [event], or direct without one. Returns its id.
  Future<String> registerDebt({
    required String me,
    required String groupId,
    required String debtorUid,
    required String creditorUid,
    required int amount,
    required String concept,
    required DateTime date,
    GroupEvent? event,
    PickedReceipt? receipt,
  }) async {
    final attachment = receipt == null
        ? null
        : await uploader.upload(receipt.path, groupId: groupId);
    return repository.registerDebt(
      LedgerMovement(
        id: '',
        groupId: groupId,
        type: LedgerMovementType.debt,
        debtorUid: debtorUid,
        creditorUid: creditorUid,
        amount: amount,
        kind: event == null ? DebtKind.direct : DebtKind.event,
        eventId: event?.id,
        eventName: event?.name,
        concept: concept.trim(),
        attachment: attachment,
        date: date,
        createdBy: me,
      ),
    );
  }

  Future<void> reject({
    required LedgerMovement movement,
    required String me,
    required RejectReason reason,
    String? note,
  }) => repository.reject(
    movement: movement,
    uid: me,
    reason: reason,
    note: _clean(note),
  );

  Future<void> delete({required LedgerMovement movement, required String me}) =>
      repository.delete(movement: movement, uid: me);

  Future<void> markSeen({
    required LedgerMovement movement,
    required String me,
  }) => repository.markSeen(movement: movement, uid: me);

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
