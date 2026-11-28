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
      // The 5.000 go to what Santi owes, not to what the user owes; the
      // 10.000 left on each side then cancel each other.
      expect(ledger.pendings, isEmpty);
      expect(ledger.offsetIds, {'beer', 'taxi'});
      expect(ledger.balance, 0);
    });

    group('opposite debts offset each other', () {
      test('only the bigger one remains, with the difference', () {
        final ledger = _ledger([
          debtOf('beer', 'me', 'santi', 5000, day: 2),
          debtOf('loan', 'santi', 'me', 10000, day: 5),
        ]);
        final loan = ledger.pendings.single;
        expect(loan.id, 'loan');
        expect(loan.remaining, 5000);
        expect(loan.offset, 5000);
        expect(loan.isPartiallyOffset, isTrue);
        expect(loan.isPartiallyPaid, isFalse);
        expect(loan.isReduced, isTrue);
        expect(loan.paidFraction, 0.5);
        expect(ledger.offsetIds, {'beer'});
        expect(ledger.balance, 5000);
        expect(ledger.pendingsOwedBy('me'), isEmpty);
      });

      test('equal debts leave nothing pending', () {
        final ledger = _ledger([
          debtOf('a', 'me', 'santi', 8000),
          debtOf('b', 'santi', 'me', 8000),
        ]);
        expect(ledger.pendings, isEmpty);
        expect(ledger.offsetIds, {'a', 'b'});
        expect(ledger.balance, 0);
      });

      test('the oldest items are cancelled first', () {
        final ledger = _ledger([
          debtOf('old', 'santi', 'me', 4000, day: 1),
          debtOf('new', 'santi', 'me', 6000, day: 3),
          debtOf('mine', 'me', 'santi', 7000, day: 2),
        ]);
        expect(ledger.offsetIds, {'old', 'mine'});
        final left = ledger.pendings.single;
        expect(left.id, 'new');
        expect(left.remaining, 3000);
        expect(ledger.balance, 3000);
      });

      test('payments apply first; only what is left is offset', () {
        final ledger = _ledger([
          debtOf('loan', 'santi', 'me', 10000, day: 1),
          debtOf('beer', 'me', 'santi', 5000, day: 2),
          paymentOf('p1', 'santi', 'me', 2000, day: 3, applied: {'loan': 2000}),
        ]);
        final loan = ledger.pendings.single;
        expect(loan.remaining, 3000);
        expect(loan.paid, 2000);
        expect(loan.offset, 5000);
        expect(ledger.balance, 3000);
      });

      test('a payment without a target settles before anything is offset', () {
        final ledger = _ledger([
          paymentOf('p1', 'santi', 'me', 6000, day: 1),
          debtOf('pizza', 'santi', 'me', 10000, day: 2),
          debtOf('beer', 'me', 'santi', 1000, day: 3),
        ]);
        final pizza = ledger.pendings.single;
        expect(pizza.id, 'pizza');
        expect(pizza.paid, 6000);
        expect(pizza.offset, 1000);
        expect(pizza.remaining, 3000);
        expect(ledger.offsetIds, {'beer'});
      });

      test('rejecting one of them undoes the offset', () {
        final ledger = _ledger([
          debtOf('beer', 'me', 'santi', 5000, status: MovementStatus.rejected),
          debtOf('loan', 'santi', 'me', 10000),
        ]);
        expect(ledger.pendings.single.remaining, 10000);
        expect(ledger.offsetIds, isEmpty);
      });

      test('debts of different groups do not offset', () {
        final a = PairLedger.compute(
          me: 'me',
          other: 'santi',
          movements: [debtOf('beer', 'me', 'santi', 5000, groupId: 'g1')],
        );
        final b = PairLedger.compute(
          me: 'me',
          other: 'santi',
          movements: [debtOf('loan', 'santi', 'me', 10000, groupId: 'g2')],
        );
        final all = PairLedger.merge(me: 'me', other: 'santi', ledgers: [a, b]);
        expect(all.pendings.map((p) => p.id), ['beer', 'loan']);
        expect(all.balance, 5000);
      });
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
