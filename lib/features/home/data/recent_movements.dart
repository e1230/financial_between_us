import '../../balances/domain/ledger_movement.dart';
import '../domain/movement.dart';
import '../presentation/home_strings.dart';

/// Movements shown in the Home.
const int recentMovementsLimit = 5;

/// The [limit] most recent active movements of [movements] that involve
/// [me], newest first, as the Home shows them. [nicknameOf] gives the
/// nickname of the other party.
List<Movement> recentMovementsOf({
  required String me,
  required List<LedgerMovement> movements,
  required String Function(String uid) nicknameOf,
  int limit = recentMovementsLimit,
}) {
  final byId = {for (final m in movements) m.id: m};
  return [
    for (final m in latestActiveOf(me: me, movements: movements, limit: limit))
      () {
        final other = nicknameOf(m.otherParty(me));
        final (type, title) = switch ((m.isPayment, m.creditorUid == me)) {
          (true, true) => (MovementType.income, HomeStrings.paidYou(other)),
          (true, false) => (MovementType.payment, HomeStrings.youPaid(other)),
          (false, true) => (MovementType.owed, HomeStrings.owesYou(other)),
          (false, false) => (MovementType.debt, HomeStrings.youOweTo(other)),
        };
        return Movement(
          id: m.id,
          type: type,
          amount: m.amount,
          title: title,
          place: _place(m, byId),
          createdAt: m.date,
        );
      }(),
  ];
}

/// The [limit] most recent active movements of [movements] between [me]
/// and someone else, newest first.
List<LedgerMovement> latestActiveOf({
  required String me,
  required List<LedgerMovement> movements,
  int limit = recentMovementsLimit,
}) => ([
  for (final m in movements)
    if (m.isActive && m.involves(me) && m.debtorUid != m.creditorUid) m,
]..sort((a, b) => compareChronologically(b, a))).take(limit).toList();

/// Event or concept of a debt; for a payment, what it settled first.
String _place(LedgerMovement m, Map<String, LedgerMovement> byId) {
  if (m.isDebt) return m.eventName ?? m.concept;
  for (final a in m.appliedTo) {
    final debt = byId[a.targetId];
    if (debt != null) return debt.eventName ?? debt.concept;
  }
  return m.note ?? m.concept;
}
