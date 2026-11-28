import '../../balances/domain/ledger_movement.dart';
import '../../balances/domain/pair_ledger.dart';
import 'activity_period.dart';
import 'period_labels.dart';

/// One slot of the chart: from [start] (inclusive) to [end] (exclusive).
typedef ActivitySlot = ({DateTime start, DateTime end});

/// The slots of [period] around [now], matching [PeriodLabels.of]: the
/// days of this week (Monday first), the weeks of this month (Monday to
/// Sunday, cut at the month edges) or the last six months.
List<ActivitySlot> activitySlots(ActivityPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case ActivityPeriod.week:
      final monday = today.subtract(Duration(days: today.weekday - 1));
      return [
        for (var i = 0; i < DateTime.daysPerWeek; i++)
          (
            start: DateTime(monday.year, monday.month, monday.day + i),
            end: DateTime(monday.year, monday.month, monday.day + i + 1),
          ),
      ];
    case ActivityPeriod.month:
      final first = DateTime(now.year, now.month);
      final next = DateTime(now.year, now.month + 1);
      final offset = first.weekday - DateTime.monday;
      return [
        for (var k = 0; k < PeriodLabels.weeksInMonth(now); k++)
          (
            start: _later(
              first,
              DateTime(first.year, first.month, 1 - offset + 7 * k),
            ),
            end: _earlier(
              next,
              DateTime(first.year, first.month, 1 - offset + 7 * (k + 1)),
            ),
          ),
      ];
    case ActivityPeriod.sixMonths:
      return [
        for (var i = 5; i >= 0; i--)
          (
            start: DateTime(now.year, now.month - i),
            end: DateTime(now.year, now.month - i + 1),
          ),
      ];
  }
}

DateTime _later(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

/// The Home chart of [uid] from the active [movements] of one group:
///
/// - "Pagado": what [uid] paid in each slot (their payments).
/// - "Te deben" / "Debes": the balances at the end of each slot, person by
///   person, so debts between the same two people already cancelled each
///   other ([PairLedger] offsets them): someone who owes [uid] 5.000 net
///   adds 5.000 to "Te deben" and nothing to "Debes".
///
/// Slots after [now] repeat the current balances and have nothing paid.
ActivitySeries activitySeriesOf({
  required String uid,
  required Iterable<LedgerMovement> movements,
  required ActivityPeriod period,
  required DateTime now,
}) {
  final mine = [
    for (final m in movements)
      if (m.isActive && m.involves(uid) && m.otherParty(uid) != uid) m,
  ];
  final others = {for (final m in mine) m.otherParty(uid)};

  final paid = <int>[];
  final owedToYou = <int>[];
  final youOwe = <int>[];
  for (final slot in activitySlots(period, now)) {
    paid.add(
      mine
          .where(
            (m) =>
                m.isPayment &&
                m.debtorUid == uid &&
                !m.date.isBefore(slot.start) &&
                m.date.isBefore(slot.end),
          )
          .fold(0, (sum, m) => sum + m.amount),
    );
    final until = [
      for (final m in mine)
        if (m.date.isBefore(slot.end)) m,
    ];
    var owed = 0;
    var owe = 0;
    for (final other in others) {
      final balance = PairLedger.compute(
        me: uid,
        other: other,
        movements: until,
      ).balance;
      if (balance > 0) owed += balance;
      if (balance < 0) owe -= balance;
    }
    owedToYou.add(owed);
    youOwe.add(owe);
  }

  return ActivitySeries(
    labels: PeriodLabels.of(period, now),
    paid: paid,
    owedToYou: owedToYou,
    youOwe: youOwe,
    paidTotal: paid.fold(0, (sum, v) => sum + v),
  );
}
