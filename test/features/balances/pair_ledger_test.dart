import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/balances/domain/pair_ledger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_builders.dart';

PairLedger _ledger(List<LedgerMovement> movements) =>
    PairLedger.compute(me: 'me', other: 'santi', movements: movements);

void main() {
  group('PairLedger', () {
    test('active debts add up, oldest pending first', () {
      final ledger = _ledger([
        debtOf('carne', 'santi', 'me', 41000, day: 22),
        debtOf('taxi', 'santi', 'me', 15000, day: 18),
        debtOf('bolos', 'santi', 'me', 26000, day: 21),
      ]);
      expect(ledger.balance, 82000);
      expect(ledger.pendings.map((p) => p.id), ['taxi', 'bolos', 'carne']);
      expect(ledger.oldestPendingAt, DateTime(2026, 11, 18));
    });

    test('a debt the user owes is negative', () {
      final ledger = _ledger([debtOf('beer', 'me', 'santi', 41500)]);
      expect(ledger.balance, -41500);
      expect(ledger.pendingsOwedBy('me').single.id, 'beer');
    });

    test('a partial payment leaves the rest pending', () {
      final ledger = _ledger([
        debtOf('bolos', 'santi', 'me', 26000, day: 21),
        paymentOf(
          'p1',
          'santi',
          'me',
          10000,
          day: 24,
          applied: {'bolos': 10000},
        ),
      ]);
      final bolos = ledger.pendings.single;
      expect(bolos.remaining, 16000);
      expect(bolos.paid, 10000);
      expect(bolos.isPartiallyPaid, isTrue);
      expect(ledger.balance, 16000);
    });

    test('a payment that covers a debt removes it from the pending list', () {
      final ledger = _ledger([
        debtOf('taxi', 'santi', 'me', 15000, day: 18),
        debtOf('carne', 'santi', 'me', 41000, day: 22),
        paymentOf(
          'p1',
          'santi',
          'me',
          15000,
          day: 24,
          applied: {'taxi': 15000},
        ),
      ]);
      expect(ledger.pendings.map((p) => p.id), ['carne']);
      expect(ledger.balance, 41000);
    });

    test('rejecting or deleting a payment brings the pending items back', () {
      for (final status in [MovementStatus.rejected, MovementStatus.deleted]) {
        final ledger = _ledger([
          debtOf('taxi', 'santi', 'me', 15000),
          paymentOf(
            'p1',
            'santi',
            'me',
            15000,
            applied: {'taxi': 15000},
            status: status,
          ),
        ]);
        expect(ledger.balance, 15000, reason: status.name);
        expect(ledger.pendings.single.remaining, 15000);
      }
    });

    test('a rejected debt does not count', () {
      final ledger = _ledger([
        debtOf('taxi', 'santi', 'me', 15000, status: MovementStatus.rejected),
      ]);
      expect(ledger.balance, 0);
      expect(ledger.pendings, isEmpty);
      expect(ledger.history.single.id, 'taxi');
    });

    test('deleted movements are hidden from the history', () {
      final ledger = _ledger([
        debtOf('taxi', 'santi', 'me', 15000, status: MovementStatus.deleted),
        debtOf('carne', 'santi', 'me', 41000, day: 2),
      ]);
      expect(ledger.history.map((m) => m.id), ['carne']);
    });

    test('a payment of a rejected debt settles the payer\'s other debts', () {
      final ledger = _ledger([
        debtOf(
          'taxi',
          'santi',
          'me',
          15000,
          day: 1,
          status: MovementStatus.rejected,
        ),
        debtOf('carne', 'santi', 'me', 41000, day: 2),
        paymentOf('p1', 'santi', 'me', 15000, day: 3, applied: {'taxi': 15000}),
      ]);
      expect(ledger.pendings.single.id, 'carne');
      expect(ledger.pendings.single.remaining, 26000);
      expect(ledger.balance, 26000);
    });

    test('what nothing can settle becomes a credit for the payer', () {
      final ledger = _ledger([
        debtOf('taxi', 'santi', 'me', 15000, status: MovementStatus.rejected),
        paymentOf('p1', 'santi', 'me', 15000, applied: {'taxi': 15000}),
      ]);
      final credit = ledger.pendings.single;
      expect(credit.kind, PendingKind.credit);
      expect(credit.id, PendingItem.creditIdFor('p1'));
      expect(credit.debtorUid, 'me');
      expect(credit.creditorUid, 'santi');
      expect(ledger.balance, -15000);
    });

    test('a later payment can settle a credit', () {
      final ledger = _ledger([
        debtOf('taxi', 'santi', 'me', 15000, status: MovementStatus.rejected),
        paymentOf('p1', 'santi', 'me', 15000, day: 2, applied: {'taxi': 15000}),
        paymentOf(
          'p2',
          'me',
          'santi',
          15000,
          day: 3,
          applied: {PendingItem.creditIdFor('p1'): 15000},
        ),
      ]);
      expect(ledger.pendings, isEmpty);
      expect(ledger.balance, 0);
    });

    test('an application in the wrong direction is not used as such', () {
      final ledger = _ledger([
        debtOf('beer', 'me', 'santi', 10000),
        debtOf('taxi', 'santi', 'me', 15000),
        paymentOf('p1', 'santi', 'me', 5000, applied: {'beer': 5000}),
      ]);
      // The 5.000 go to what Santi owes, not to what the user owes.
      expect(
        {for (final p in ledger.pendings) p.id: p.remaining},
        {'beer': 10000, 'taxi': 10000},
      );
      expect(ledger.balance, 0);
    });

    test('ignores movements of other people', () {
      final ledger = _ledger([
        debtOf('x', 'santi', 'juli', 9000),
        debtOf('y', 'juli', 'me', 9000),
      ]);
      expect(ledger.history, isEmpty);
      expect(ledger.balance, 0);
    });

    test(
      'counts movements the other registered that the user did not open',
      () {
        final ledger = _ledger([
          paymentOf('p1', 'santi', 'me', 1000, createdBy: 'santi'),
          paymentOf(
            'p2',
            'santi',
            'me',
            1000,
            createdBy: 'santi',
            seenBy: ['santi', 'me'],
          ),
          debtOf('d1', 'santi', 'me', 9000, createdBy: 'me'),
        ]);
        expect(ledger.newCount, 1);
      },
    );

    test('merge joins the ledgers of several groups', () {
      final a = PairLedger.compute(
        me: 'me',
        other: 'santi',
        movements: [debtOf('a', 'santi', 'me', 18000, day: 5)],
      );
      final b = PairLedger.compute(
        me: 'me',
        other: 'santi',
        movements: [debtOf('b', 'santi', 'me', 72000, day: 2, groupId: 'g2')],
      );
      final merged = PairLedger.merge(
        me: 'me',
        other: 'santi',
        ledgers: [a, b],
      );
      expect(merged.balance, 90000);
      expect(merged.pendings.map((p) => p.id), ['b', 'a']);
      expect(merged.history.map((m) => m.id), ['a', 'b']);
    });
  });
}
