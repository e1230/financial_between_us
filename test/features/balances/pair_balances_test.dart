import 'package:financial_between_us/features/balances/domain/debt.dart';
import 'package:financial_between_us/features/balances/domain/pair_balances.dart';
import 'package:flutter_test/flutter_test.dart';

Debt _d(String from, String to, int amount) =>
    Debt(fromUid: from, toUid: to, amount: amount);

void main() {
  group('balancesWith', () {
    test('positive when they owe me, negative when I owe them', () {
      final balances = balancesWith('me', [
        _d('ana', 'me', 32000),
        _d('me', 'beto', 41500),
      ]);
      expect(balances, {'ana': 32000, 'beto': -41500});
    });

    test('crossed debts offset each other', () {
      expect(
        balancesWith('me', [_d('ana', 'me', 30000), _d('me', 'ana', 12000)]),
        {'ana': 18000},
      );
      expect(
        balancesWith('me', [_d('ana', 'me', 5000), _d('me', 'ana', 9000)]),
        {'ana': -4000},
      );
    });

    test('people who are even, self debts and other pairs are left out', () {
      final balances = balancesWith('me', [
        _d('ana', 'me', 10000),
        _d('me', 'ana', 10000),
        _d('me', 'me', 5000),
        _d('beto', 'carla', 7000),
      ]);
      expect(balances, isEmpty);
    });

    test('adds several debts with the same person', () {
      expect(
        balancesWith('me', [
          _d('ana', 'me', 1000),
          _d('ana', 'me', 2500),
          _d('beto', 'me', 400),
        ]),
        {'ana': 3500, 'beto': 400},
      );
    });
  });

  test('netBalance adds what others owe minus what one owes', () {
    final debts = [
      _d('ana', 'me', 32000),
      _d('me', 'beto', 41500),
      _d('carla', 'beto', 1000),
    ];
    expect(netBalance('me', debts), -9500);
    expect(netBalance('beto', debts), 42500);
    expect(netBalance('dora', debts), 0);
  });
}
