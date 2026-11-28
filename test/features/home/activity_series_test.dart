import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/home/data/home_activity_repository.dart';
import 'package:financial_between_us/features/home/domain/activity_period.dart';
import 'package:financial_between_us/features/home/domain/activity_series_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/ledger_builders.dart';
import '../../support/movements_fakes.dart';

/// Wednesday 25 Nov 2026, 9 pm.
final DateTime _now = DateTime(2026, 11, 25, 21);

LedgerMovement _on(LedgerMovement m, DateTime date) => m.copyWith(date: date);

void main() {
  group('activitySlots', () {
    test('this week, Monday to Sunday', () {
      final slots = activitySlots(ActivityPeriod.week, _now);
      expect(slots, hasLength(7));
      expect(slots.first.start, DateTime(2026, 11, 23));
      expect(slots.last.end, DateTime(2026, 11, 30));
    });

    test('the weeks of this month, cut at its edges', () {
      final slots = activitySlots(ActivityPeriod.month, _now);
      // November 2026 starts on a Sunday: 6 weeks touch it.
      expect(slots, hasLength(6));
      expect(slots.first, (
        start: DateTime(2026, 11, 1),
        end: DateTime(2026, 11, 2),
      ));
      expect(slots.last, (
        start: DateTime(2026, 11, 30),
        end: DateTime(2026, 12, 1),
      ));
    });

    test('the last six months', () {
      final slots = activitySlots(ActivityPeriod.sixMonths, _now);
      expect(slots.first.start, DateTime(2026, 6));
      expect(slots.last, (start: DateTime(2026, 11), end: DateTime(2026, 12)));
    });
  });

  group('activitySeriesOf', () {
    test('opposite debts are netted person by person', () {
      final series = activitySeriesOf(
        uid: 'me',
        period: ActivityPeriod.week,
        now: _now,
        movements: [
          // The user owes Santi 5.000; Santi owes the user 10.000.
          _on(debtOf('beer', 'me', 'santi', 5000), DateTime(2026, 11, 23, 12)),
          _on(debtOf('loan', 'santi', 'me', 10000), DateTime(2026, 11, 24, 12)),
          // And the user owes Juli 3.000.
          _on(debtOf('taxi', 'me', 'juli', 3000), DateTime(2026, 11, 24, 13)),
        ],
      );
      expect(series.labels, ['L', 'M', 'M', 'J', 'V', 'S', 'D']);
      // Monday: only the beer.
      expect(series.owedToYou[0], 0);
      expect(series.youOwe[0], 5000);
      // Tuesday on: Santi owes 5.000 net; the user owes only Juli.
      expect(series.owedToYou.sublist(1), everyElement(5000));
      expect(series.youOwe.sublist(1), everyElement(3000));
      expect(series.owedToYouNow, 5000);
      expect(series.youOweNow, 3000);
    });

    test('"Pagado" adds the payments the user made in each slot', () {
      final series = activitySeriesOf(
        uid: 'me',
        period: ActivityPeriod.sixMonths,
        now: _now,
        movements: [
          _on(debtOf('d1', 'me', 'santi', 30000), DateTime(2026, 9, 3)),
          _on(
            paymentOf('p1', 'me', 'santi', 10000, applied: {'d1': 10000}),
            DateTime(2026, 10, 5),
          ),
          _on(
            paymentOf('p2', 'me', 'santi', 5000, applied: {'d1': 5000}),
            DateTime(2026, 11, 2),
          ),
          // Received, not paid: with nothing to settle it becomes a
          // "Saldo a favor" the user owes back.
          _on(paymentOf('p3', 'santi', 'me', 7000), DateTime(2026, 11, 3)),
          // Before the period.
          _on(paymentOf('p0', 'me', 'santi', 999), DateTime(2026, 5, 31)),
        ],
      );
      expect(series.labels, ['Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov']);
      expect(series.paid, [0, 0, 0, 0, 10000, 5000]);
      expect(series.paidTotal, 15000);
      // The 999 paid before the debt settle part of it too.
      expect(series.youOwe, [0, 0, 0, 29001, 19001, 14001 + 7000]);
    });

    test('rejected movements and other people are left out', () {
      final series = activitySeriesOf(
        uid: 'me',
        period: ActivityPeriod.month,
        now: _now,
        movements: [
          _on(
            debtOf('x', 'santi', 'me', 9000, status: MovementStatus.rejected),
            DateTime(2026, 11, 10),
          ),
          _on(debtOf('y', 'santi', 'juli', 9000), DateTime(2026, 11, 10)),
        ],
      );
      expect(series.maxValue, 0);
    });
  });

  test('the repository follows the live movements of the group', () async {
    final movements = FakeMovementsRepository([
      _on(
        debtOf('loan', 'santi', 'me', 10000, groupId: sampleGroupId),
        DateTime(2026, 11, 20),
      ),
    ]);
    final repo = MovementsHomeActivityRepository(movements, clock: () => _now);
    final series = await repo
        .watchSeries(
          groupId: sampleGroupId,
          uid: 'me',
          period: ActivityPeriod.week,
        )
        .first;
    expect(series.owedToYouNow, 10000);
  });
}
