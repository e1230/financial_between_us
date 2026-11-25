import 'activity_period.dart';

/// X axis labels of the Home chart.
abstract final class PeriodLabels {
  static const List<String> weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  static const List<String> months = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', //
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  /// Labels of [period] ending at [now]: the last six months ("Jun" …
  /// "Nov"), the weeks of the month ("S1" … "S5") or the days of the week.
  static List<String> of(ActivityPeriod period, DateTime now) =>
      switch (period) {
        ActivityPeriod.week => weekDays,
        ActivityPeriod.month => [
          for (var i = 1; i <= weeksInMonth(now); i++) 'S$i',
        ],
        ActivityPeriod.sixMonths => [
          for (var i = 5; i >= 0; i--) months[(now.month - 1 - i) % 12],
        ],
      };

  /// Weeks (Monday to Sunday) the month of [date] touches: 4 to 6.
  static int weeksInMonth(DateTime date) {
    final first = DateTime(date.year, date.month);
    final days = DateTime(date.year, date.month + 1, 0).day;
    final offset = first.weekday - DateTime.monday;
    return ((offset + days) / DateTime.daysPerWeek).ceil();
  }
}
