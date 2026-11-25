import 'package:financial_between_us/core/utils/relative_date_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  final now = DateTime(2026, 11, 25, 21);

  test('today shows the time', () {
    final text = RelativeDateFormat.format(
      DateTime(2026, 11, 25, 20, 15),
      now: now,
    );
    // es_CO separates the period with non-breaking spaces.
    expect(text.replaceAll(RegExp(r'\s'), ' '), 'Hoy, 8:15 p. m.');
  });

  test('yesterday is a calendar day, not 24 hours', () {
    expect(
      RelativeDateFormat.format(DateTime(2026, 11, 24, 23, 59), now: now),
      'Ayer',
    );
    expect(
      RelativeDateFormat.format(
        DateTime(2026, 11, 24, 0, 1),
        now: DateTime(2026, 11, 25, 0, 2),
      ),
      'Ayer',
    );
  });

  test('older dates show day and short month without a dot', () {
    expect(
      RelativeDateFormat.format(DateTime(2026, 11, 22, 13), now: now),
      '22 nov',
    );
  });

  test('dates of another year include the year', () {
    expect(
      RelativeDateFormat.format(DateTime(2025, 9, 3), now: now),
      '3 sept 2025',
    );
  });
}
