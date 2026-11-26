/// [fromUid] owes [toUid] [amount] whole pesos (COP) in a group.
///
/// The raw material of every balance: balances are computed from debts,
/// never stored.
final class Debt {
  const Debt({required this.fromUid, required this.toUid, required this.amount})
    : assert(amount > 0, 'A debt is always positive');

  final String fromUid;
  final String toUid;

  /// Whole pesos, always positive.
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is Debt &&
      other.fromUid == fromUid &&
      other.toUid == toUid &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(fromUid, toUid, amount);

  @override
  String toString() => 'Debt($fromUid → $toUid: $amount)';
}
