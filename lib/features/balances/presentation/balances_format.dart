import 'package:intl/intl.dart';

import '../../payment_accounts/domain/payment_account_rules.dart';
import '../../profile/domain/user_profile.dart';

/// Dates of the balances module, in Colombian Spanish.
///
/// Needs `initializeDateFormatting('es_CO')` (done by app startup).
abstract final class BalancesDates {
  static const String locale = 'es_CO';

  /// "18 nov" ("18 nov 2025" in another year than [now]).
  static String short(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final pattern = date.year == current.year ? 'd MMM' : 'd MMM y';
    return DateFormat(pattern, locale).format(date).replaceAll('.', '');
  }

  /// "hoy", "ayer" or [short].
  static String relative(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final days = _day(current).difference(_day(date)).inDays;
    if (days == 0) return 'hoy';
    if (days == 1) return 'ayer';
    return short(date, now: current);
  }

  /// "18 nov, 6:30 p. m.".
  static String withTime(DateTime date, {DateTime? now}) =>
      '${short(date, now: now)}, ${DateFormat('h:mm a', locale).format(date)}';

  /// "NOVIEMBRE" ("NOVIEMBRE 2025" in another year than [now]).
  static String month(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final pattern = date.year == current.year ? 'MMMM' : 'MMMM y';
    return DateFormat(pattern, locale).format(date).toUpperCase();
  }

  /// "22 de noviembre", for screen readers.
  static String spoken(DateTime date) =>
      DateFormat("d 'de' MMMM", locale).format(date);

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

/// Names of a person as the balances screens show them; empty while the
/// profile loads.
abstract final class PersonNames {
  /// "Santiago Ruiz" (the nickname if there is no name).
  static String full(UserProfile? profile) {
    if (profile == null) return '';
    final name = profile.displayName.trim();
    return name.isEmpty ? profile.nickname : name;
  }

  /// "Santiago".
  static String first(UserProfile? profile) =>
      PaymentAccountRules.firstName(full(profile));

  /// "santi".
  static String nickname(UserProfile? profile) => profile?.nickname ?? '';
}
