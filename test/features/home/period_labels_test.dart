import 'package:financial_between_us/features/home/domain/activity_period.dart';
import 'package:financial_between_us/features/home/domain/period_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('six months end at the current month and wrap the year', () {
    expect(PeriodLabels.of(ActivityPeriod.sixMonths, DateTime(2026, 11, 25)), [
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
    ]);
    expect(PeriodLabels.of(ActivityPeriod.sixMonths, DateTime(2026, 2, 1)), [
      'Sep',
      'Oct',
      'Nov',
      'Dic',
      'Ene',
      'Feb',
    ]);
  });

  test('month shows one label per week it touches', () {
    // November 2026 starts on a Sunday: 6 Monday-to-Sunday weeks.
    expect(PeriodLabels.weeksInMonth(DateTime(2026, 11)), 6);
    // February 2027 starts on a Monday and has 28 days: 4 weeks.
    expect(PeriodLabels.weeksInMonth(DateTime(2027, 2)), 4);
    expect(PeriodLabels.of(ActivityPeriod.month, DateTime(2027, 2)), [
      'S1',
      'S2',
      'S3',
      'S4',
    ]);
  });

  test('week shows the days', () {
    expect(PeriodLabels.of(ActivityPeriod.week, DateTime(2026, 11, 25)), [
      'L',
      'M',
      'M',
      'J',
      'V',
      'S',
      'D',
    ]);
  });

  test('series summary values', () {
    final series = ActivitySeries(
      labels: ['a', 'b'],
      paid: [10, 20],
      owedToYou: [5, 7],
      youOwe: [30, 1],
      paidTotal: 30,
    );
    expect(series.owedToYouNow, 7);
    expect(series.youOweNow, 1);
    expect(series.maxValue, 30);
  });
}
