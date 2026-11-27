import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';

/// A debt of [amount] that [from] owes [to], dated on [day] of November.
LedgerMovement debtOf(
  String id,
  String from,
  String to,
  int amount, {
  int day = 1,
  String groupId = 'g1',
  DebtKind kind = DebtKind.direct,
  String concept = 'Concepto',
  String? eventName,
  MovementStatus status = MovementStatus.active,
  String? createdBy,
  List<String> seenBy = const [],
}) => LedgerMovement(
  id: id,
  groupId: groupId,
  type: LedgerMovementType.debt,
  debtorUid: from,
  creditorUid: to,
  amount: amount,
  kind: kind,
  concept: concept,
  eventName: eventName,
  date: DateTime(2026, 11, day),
  createdBy: createdBy ?? to,
  status: status,
  seenBy: seenBy,
);

/// A payment of [amount] from [from] to [to], dated on [day] of November.
LedgerMovement paymentOf(
  String id,
  String from,
  String to,
  int amount, {
  int day = 1,
  String groupId = 'g1',
  Map<String, int> applied = const {},
  MovementStatus status = MovementStatus.active,
  String? createdBy,
  List<String> seenBy = const [],
}) => LedgerMovement(
  id: id,
  groupId: groupId,
  type: LedgerMovementType.payment,
  debtorUid: from,
  creditorUid: to,
  amount: amount,
  appliedTo: [
    for (final e in applied.entries)
      PaymentApplication(targetId: e.key, amount: e.value),
  ],
  date: DateTime(2026, 11, day),
  createdBy: createdBy ?? from,
  status: status,
  seenBy: seenBy,
);
