import 'package:financial_between_us/features/balances/domain/pair_ledger.dart';
import 'package:financial_between_us/features/balances/domain/payment_allocation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_builders.dart';

void main() {
  final pendings = PairLedger.compute(
    me: 'me',
    other: 'santi',
    movements: [
      debtOf('taxi', 'santi', 'me', 15000, day: 18),
      debtOf('bolos', 'santi', 'me', 26000, day: 21),
      debtOf('carne', 'santi', 'me', 41000, day: 22),
      paymentOf('p0', 'santi', 'me', 10000, day: 24, applied: {'bolos': 10000}),
    ],
  ).pendings;

  Map<String, int> split(int amount, [Set<String>? selected]) => {
    for (final a in allocatePayment(
      amount: amount,
      pendings: pendings,
      selectedIds: selected,
    ))
      a.item.id: a.amount,
  };

  test('the whole pending amount covers every item', () {
    expect(pendingTotal(pendings), 72000);
    expect(split(72000), {'taxi': 15000, 'bolos': 16000, 'carne': 41000});
  });

  test('oldest first, the last one may be partial', () {
    final allocations = allocatePayment(amount: 20000, pendings: pendings);
    expect(
      {for (final a in allocations) a.item.id: a.amount},
      {'taxi': 15000, 'bolos': 5000},
    );
    expect(allocations.last.isPartial, isTrue);
    expect(allocations.first.isPartial, isFalse);
  });

  test('only selected items take part', () {
    expect(pendingTotal(pendings, {'carne', 'taxi'}), 56000);
    expect(split(50000, {'carne', 'taxi'}), {'taxi': 15000, 'carne': 35000});
  });

  test('money beyond the selected items is not allocated', () {
    expect(split(99000, {'taxi'}), {'taxi': 15000});
  });

  test('zero allocates nothing', () {
    expect(split(0), isEmpty);
  });

  test('allocations become applications', () {
    final a = allocatePayment(amount: 1000, pendings: pendings).single;
    expect(a.toApplication().targetId, 'taxi');
    expect(a.toApplication().amount, 1000);
  });
}
