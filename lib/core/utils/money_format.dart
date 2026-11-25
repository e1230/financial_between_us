import 'package:intl/intl.dart';

/// Formats amounts in Colombian pesos: whole pesos (never `double`), with
/// `es_CO` grouping, like `$ 48.500`.
abstract final class MoneyFormat {
  static const String locale = 'es_CO';

  /// U+2212, the typographic minus sign.
  static const String minus = '−';

  static final NumberFormat _number = NumberFormat.decimalPattern(locale);

  /// `$ 48.500`. Negative amounts are shown as their absolute value; use
  /// [signed] to show the sign.
  static String format(int pesos) => '\$ ${_number.format(pesos.abs())}';

  /// `+$ 32.000` for a positive [pesos] and `−$ 248.000` for a negative one.
  static String signed(int pesos) {
    if (pesos == 0) return format(0);
    return '${pesos > 0 ? '+' : minus}${format(pesos)}';
  }
}
