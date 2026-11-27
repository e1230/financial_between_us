import 'package:financial_between_us/features/balances/domain/debt.dart';
import 'package:financial_between_us/features/balances/domain/debt_simplification.dart';
import 'package:financial_between_us/features/balances/domain/pair_balances.dart';
import 'package:flutter_test/flutter_test.dart';

/// Net balance of each person after [transfers].
Map<String, int> _nets(Iterable<String> people, List<Debt> transfers) => {
  for (final uid in people) uid: netBalance(uid, transfers),
};

void main() {
  test('nobody owes: no transfers', () {
    expect(simplifyDebts({'a': 0, 'b': 0}), isEmpty);
    expect(simplifyDebts({}), isEmpty);
  });

  test('a chain collapses into one transfer', () {
    // a owes b 10.000 and b owes c 10.000: a pays c directly.
    expect(simplifyDebts({'a': -10000, 'b': 0, 'c': 10000}), [
      const Debt(fromUid: 'a', toUid: 'c', amount: 10000),
    ]);
  });

  test('the transfers settle every net balance', () {
    final nets = {'a': -45000, 'b': -15000, 'c': 30000, 'd': 20000, 'e': 10000};
    final transfers = simplifyDebts(nets);
    expect(_nets(nets.keys, transfers), nets);
    expect(transfers.length, lessThanOrEqualTo(nets.length - 1));
  });

  test('nobody both pays and receives', () {
    final transfers = simplifyDebts({
      'a': -30000,
      'b': -20000,
      'c': 25000,
      'd': 25000,
    });
    final payers = {for (final t in transfers) t.fromUid};
    final receivers = {for (final t in transfers) t.toUid};
    expect(payers.intersection(receivers), isEmpty);
  });

  test('is deterministic on ties', () {
    final nets = {'b': -10000, 'a': -10000, 'd': 10000, 'c': 10000};
    expect(simplifyDebts(nets), simplifyDebts(Map.of(nets)));
    expect(
      simplifyDebts(nets).first,
      const Debt(fromUid: 'a', toUid: 'c', amount: 10000),
    );
  });
}
