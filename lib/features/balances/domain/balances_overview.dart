import 'debt.dart';
import 'ledger_movement.dart';
import 'pair_ledger.dart';

/// Movements and members of one group, the raw material of the overview.
final class GroupLedgerInput {
  const GroupLedgerInput({
    required this.groupId,
    required this.memberUids,
    required this.movements,
  });

  final String groupId;

  /// Active members.
  final List<String> memberUids;
  final List<LedgerMovement> movements;
}

/// Where the user stands with one person across the groups of a scope.
final class PersonBalance {
  const PersonBalance({
    required this.uid,
    required this.balance,
    required this.pendingCount,
    required this.newCount,
    required this.groupIds,
    required this.lastActivityAt,
  });

  final String uid;

  /// Whole pesos: positive "te debe", negative "le debes", zero even.
  final int balance;

  /// Pending items between both, in either direction.
  final int pendingCount;

  /// Movements they registered that the user has not opened.
  final int newCount;

  /// Groups of the scope they share with the user (or where they have
  /// movements together).
  final List<String> groupIds;
  final DateTime? lastActivityAt;
}

/// The balances screen: what the user is owed, what they owe and who is
/// even, in one group or across all of them.
final class BalancesOverview {
  const BalancesOverview({
    required this.owedToMe,
    required this.iOwe,
    required this.settled,
    required this.groupCount,
  });

  /// Balances of [me] in each group of [groups], added up by person.
  factory BalancesOverview.compute({
    required String me,
    required List<GroupLedgerInput> groups,
  }) {
    final byUid = <String, _Accumulator>{};
    for (final group in groups) {
      final others = <String>{
        for (final uid in group.memberUids)
          if (uid != me) uid,
        for (final m in group.movements)
          if (m.involves(me) && m.otherParty(me) != me) m.otherParty(me),
      };
      for (final other in others) {
        final ledger = PairLedger.compute(
          me: me,
          other: other,
          movements: group.movements,
        );
        final isMember = group.memberUids.contains(other);
        if (!isMember && ledger.history.isEmpty) continue;
        byUid.putIfAbsent(other, () => _Accumulator(other))
          ..add(group.groupId, ledger)
          ..isMember |= isMember;
      }
    }

    final people = [
      for (final a in byUid.values)
        if (a.balance != 0 || a.isMember) a.toPerson(),
    ];
    int biggestFirst(PersonBalance a, PersonBalance b) {
      final byAmount = b.balance.abs().compareTo(a.balance.abs());
      return byAmount != 0 ? byAmount : a.uid.compareTo(b.uid);
    }

    return BalancesOverview(
      owedToMe: [
        for (final p in people)
          if (p.balance > 0) p,
      ]..sort(biggestFirst),
      iOwe: [
        for (final p in people)
          if (p.balance < 0) p,
      ]..sort(biggestFirst),
      settled: [
        for (final p in people)
          if (p.balance == 0) p,
      ]..sort((a, b) => a.uid.compareTo(b.uid)),
      groupCount: groups.length,
    );
  }

  /// People who owe the user, biggest first.
  final List<PersonBalance> owedToMe;

  /// People the user owes, biggest first.
  final List<PersonBalance> iOwe;

  /// Members with nothing pending with the user.
  final List<PersonBalance> settled;

  /// Groups in the scope.
  final int groupCount;

  /// Whole pesos the user is owed ("Te deben").
  int get owedToMeTotal => owedToMe.fold(0, (sum, p) => sum + p.balance);

  /// Whole pesos the user owes ("Debes"), positive.
  int get iOweTotal => iOwe.fold(0, (sum, p) => sum - p.balance);

  /// "Balance neto": positive in favor of the user.
  int get net => owedToMeTotal - iOweTotal;

  /// Nobody owes the user and they owe nobody.
  bool get isAllClear => owedToMe.isEmpty && iOwe.isEmpty;
}

class _Accumulator {
  _Accumulator(this.uid);

  final String uid;
  int balance = 0;
  int pendingCount = 0;
  int newCount = 0;
  bool isMember = false;
  final List<String> groupIds = [];
  DateTime? lastActivityAt;

  void add(String groupId, PairLedger ledger) {
    balance += ledger.balance;
    pendingCount += ledger.pendings.length;
    newCount += ledger.newCount;
    groupIds.add(groupId);
    final last = ledger.lastActivityAt;
    if (last != null &&
        (lastActivityAt == null || last.isAfter(lastActivityAt!))) {
      lastActivityAt = last;
    }
  }

  PersonBalance toPerson() => PersonBalance(
    uid: uid,
    balance: balance,
    pendingCount: pendingCount,
    newCount: newCount,
    groupIds: List.unmodifiable(groupIds),
    lastActivityAt: lastActivityAt,
  );
}

/// What is still owed between every pair of people in [movements] (one
/// group), as [Debt]s: the input of `balancesWith`, `netBalance` and
/// `simplifyDebts`.
List<Debt> debtsFromMovements(Iterable<LedgerMovement> movements) {
  final list = movements.toList();
  final pairs = <(String, String)>{
    for (final m in list)
      if (m.debtorUid != m.creditorUid)
        m.debtorUid.compareTo(m.creditorUid) < 0
            ? (m.debtorUid, m.creditorUid)
            : (m.creditorUid, m.debtorUid),
  };
  return [
    for (final (a, b) in pairs)
      for (final p in PairLedger.compute(
        me: a,
        other: b,
        movements: list,
      ).pendings)
        Debt(fromUid: p.debtorUid, toUid: p.creditorUid, amount: p.remaining),
  ];
}
