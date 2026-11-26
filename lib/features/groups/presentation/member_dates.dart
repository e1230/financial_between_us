import 'package:intl/intl.dart';

/// Dates of the group detail, in Colombian Spanish: "22 nov 2026".
///
/// Needs `initializeDateFormatting('es_CO')` (done by app startup).
abstract final class MemberDates {
  static const String locale = 'es_CO';

  /// "22 nov 2026" (without the abbreviation dot of `es_CO`).
  static String format(DateTime date) =>
      DateFormat('d MMM y', locale).format(date.toLocal()).replaceAll('.', '');
}
