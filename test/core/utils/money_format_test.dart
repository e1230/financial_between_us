import 'package:financial_between_us/core/utils/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats whole pesos with es_CO grouping', () {
    expect(MoneyFormat.format(48500), r'$ 48.500');
    expect(MoneyFormat.format(412000), r'$ 412.000');
    expect(MoneyFormat.format(1250000), r'$ 1.250.000');
    expect(MoneyFormat.format(0), r'$ 0');
  });

  test('negative amounts are formatted as absolute values', () {
    expect(MoneyFormat.format(-41500), r'$ 41.500');
  });

  test('signed amounts use + and the U+2212 minus sign', () {
    expect(MoneyFormat.signed(32000), r'+$ 32.000');
    expect(MoneyFormat.signed(-248000), '−\$ 248.000');
    expect(MoneyFormat.signed(0), r'$ 0');
  });
}
