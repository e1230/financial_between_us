import 'package:financial_between_us/features/balances/domain/balances_overview.dart';
import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/balances/domain/pair_balances.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_builders.dart';

void main() {
  final lowIq = GroupLedgerInput(
    groupId: 'g1',
    memberUids: const ['me', 'santi', 'juli', 'valen', 'feli'],
    movements: [
      debtOf('a', 'santi', 'me', 72000, day: 18),
      debtOf('b', 'juli', 'me', 58500, day: 19),
      debtOf('c', 'me', 'valen', 45000, day: 20),
      paymentOf(
        'p',
        'santi',
        'me',
        2000,
        day: 21,
        applied: {'a': 2000},
        createdBy: 'santi',
      ),
    ],
  );
  final futbol = GroupLedgerInput(
    groupId: 'g2',
    memberUids: const ['me', 'santi'],
    movements: [debtOf('d', 'santi', 'me', 18000, groupId: 'g2')],
  );

  test('splits people into owed, owing and even, biggest first', () {
    final o = BalancesOverview.compute(me: 'me', groups: [lowIq]);
    expect(o.owedToMe.map((p) => p.uid), ['santi', 'juli']);
    expect(o.owedToMe.first.balance, 70000);
    expect(o.iOwe.single.uid, 'valen');
    expect(o.settled.single.uid, 'feli');
    expect(o.owedToMeTotal, 128500);
    expect(o.iOweTotal, 45000);
    expect(o.net, 83500);
    expect(o.isAllClear, isFalse);
  });

  test('counts pending items and new movements per person', () {
    final o = BalancesOverview.compute(me: 'me', groups: [lowIq]);
    final santi = o.owedToMe.first;
    expect(santi.pendingCount, 1);
    expect(santi.newCount, 1);
    expect(santi.groupIds, ['g1']);
  });

  test('"Todos los grupos" adds each person up across groups', () {
    final o = BalancesOverview.compute(me: 'me', groups: [lowIq, futbol]);
    final santi = o.owedToMe.firstWhere((p) => p.uid == 'santi');
    expect(santi.balance, 88000);
    expect(santi.groupIds, ['g1', 'g2']);
    expect(o.groupCount, 2);
  });

  test('a former member with a balance still shows up', () {
    final o = BalancesOverview.compute(
      me: 'me',
      groups: [
        GroupLedgerInput(
          groupId: 'g1',
          memberUids: const ['me'],
          movements: [debtOf('x', 'ana', 'me', 5000)],
        ),
      ],
    );
    expect(o.owedToMe.single.uid, 'ana');
    expect(o.settled, isEmpty);
  });

  test('all clear when nobody owes', () {
    final o = BalancesOverview.compute(
      me: 'me',
      groups: [
        GroupLedgerInput(
          groupId: 'g1',
          memberUids: const ['me', 'ana'],
          movements: [
            debtOf('x', 'ana', 'me', 5000),
            paymentOf('p', 'ana', 'me', 5000, applied: {'x': 5000}),
          ],
        ),
      ],
    );
    expect(o.isAllClear, isTrue);
    expect(o.net, 0);
    expect(o.settled.single.lastActivityAt, DateTime(2026, 11, 1));
  });

  test('debtsFromMovements feeds balancesWith and netBalance', () {
    final movements = <LedgerMovement>[
      debtOf('a', 'santi', 'me', 72000),
      debtOf('b', 'juli', 'santi', 10000),
      paymentOf('p', 'santi', 'me', 2000, applied: {'a': 2000}),
    ];
    final debts = debtsFromMovements(movements);
    expect(balancesWith('me', debts), {'santi': 70000});
    expect(netBalance('santi', debts), -60000);
    expect(netBalance('juli', debts), -10000);
  });
}
