import 'debt.dart';

/// The fewest transfers (in practice) that settle a group whose members
/// have the net balances [nets] (uid → whole pesos: positive is owed to
/// them, negative they owe).
///
/// Greedy: the biggest debtor pays the biggest creditor as much as both
/// allow, until everybody is even. It needs at most `n − 1` transfers for
/// `n` people with a balance, and nobody both pays and receives. Ties are
/// broken by uid, so the result is deterministic.
///
/// The nets must add up to zero (they do when they come from the same
/// debts, see `netBalance`).
// TODO: show these transfers as suggestions ("Para quedar a paz y salvo")
// when the group view needs them; the balances screen works by pairs.
List<Debt> simplifyDebts(Map<String, int> nets) {
  assert(
    nets.values.fold(0, (sum, v) => sum + v) == 0,
    'Net balances must add up to zero',
  );
  final creditors = [
    for (final e in nets.entries)
      if (e.value > 0) _Party(e.key, e.value),
  ];
  final debtors = [
    for (final e in nets.entries)
      if (e.value < 0) _Party(e.key, -e.value),
  ];

  final transfers = <Debt>[];
  while (creditors.isNotEmpty && debtors.isNotEmpty) {
    creditors.sort(_biggestFirst);
    debtors.sort(_biggestFirst);
    final creditor = creditors.first;
    final debtor = debtors.first;
    final amount = creditor.amount < debtor.amount
        ? creditor.amount
        : debtor.amount;
    transfers.add(
      Debt(fromUid: debtor.uid, toUid: creditor.uid, amount: amount),
    );
    creditor.amount -= amount;
    debtor.amount -= amount;
    if (creditor.amount == 0) creditors.removeAt(0);
    if (debtor.amount == 0) debtors.removeAt(0);
  }
  return transfers;
}

class _Party {
  _Party(this.uid, this.amount);

  final String uid;
  int amount;
}

int _biggestFirst(_Party a, _Party b) {
  final byAmount = b.amount.compareTo(a.amount);
  return byAmount != 0 ? byAmount : a.uid.compareTo(b.uid);
}
