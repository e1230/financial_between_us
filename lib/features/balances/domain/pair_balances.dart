import 'debt.dart';

/// Net balance of [uid] with each person of [debts], in whole pesos:
/// positive when that person owes [uid] ("Te debe"), negative when [uid]
/// owes them ("Debes"). People who are even, and debts of someone with
/// themselves, are left out.
Map<String, int> balancesWith(String uid, Iterable<Debt> debts) {
  final net = <String, int>{};
  for (final debt in debts) {
    if (debt.fromUid == debt.toUid) continue;
    if (debt.toUid == uid) {
      net.update(
        debt.fromUid,
        (v) => v + debt.amount,
        ifAbsent: () => debt.amount,
      );
    } else if (debt.fromUid == uid) {
      net.update(
        debt.toUid,
        (v) => v - debt.amount,
        ifAbsent: () => -debt.amount,
      );
    }
  }
  net.removeWhere((_, amount) => amount == 0);
  return net;
}

/// Total balance of [uid] in the group: what others owe them minus what
/// they owe. Zero means they are even with everyone.
int netBalance(String uid, Iterable<Debt> debts) =>
    balancesWith(uid, debts).values.fold(0, (sum, amount) => sum + amount);
