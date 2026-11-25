import 'package:intl/intl.dart';

/// Short relative dates of lists, in Colombian Spanish:
/// "Hoy, 8:15 p. m.", "Ayer" and, from two days back, "22 nov".
///
/// Needs `initializeDateFormatting('es_CO')` (done by app startup).
abstract final class RelativeDateFormat {
  static const String locale = 'es_CO';

  static const String today = 'Hoy';
  static const String yesterday = 'Ayer';

  /// Formats [date] relative to [now] (defaults to the current time).
  static String format(DateTime date, {DateTime? now}) {
    final local = date.toLocal();
    final current = (now ?? DateTime.now()).toLocal();
    final days = _day(current).difference(_day(local)).inDays;
    if (days == 0) {
      return '$today, ${DateFormat('h:mm a', locale).format(local)}';
    }
    if (days == 1) return yesterday;
    // DECISIÓN: dates of another year also show the year ("22 nov 2025").
    final pattern = local.year == current.year ? 'd MMM' : 'd MMM y';
    return DateFormat(pattern, locale).format(local).replaceAll('.', '');
  }

  /// Midnight of [date]; days are compared by calendar date, not 24 h.
  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
