import 'package:financial_between_us/core/theme/app_tokens.dart';
import 'package:financial_between_us/core/utils/accent_color.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('every preset is readable with #111111 text', () {
    for (final value in AccentColor.presets) {
      expect(
        AccentColor.isReadable(Color(value)),
        isTrue,
        reason: AccentColor.toHex(value),
      );
    }
  });

  test('the brand green is the first preset and the fallback', () {
    expect(AccentColor.presets.first, AppTokens.dark.accent.toARGB32());
    expect(AccentColor.fallback, AppTokens.dark.accent);
  });

  test('dark and saturated blue colors are not readable', () {
    expect(AccentColor.isReadable(const Color(0xFF0000FF)), isFalse);
    expect(AccentColor.isReadable(const Color(0xFF333333)), isFalse);
  });

  test('makeReadable keeps readable colors untouched', () {
    final green = HSVColor.fromColor(AppTokens.dark.accent);
    expect(AccentColor.makeReadable(green), green);
  });

  test('makeReadable brightens dark colors, keeping the hue', () {
    final dark = HSVColor.fromAHSV(1, 120, 0.8, 0.2);
    final fixed = AccentColor.makeReadable(dark);
    expect(AccentColor.isReadable(fixed.toColor()), isTrue);
    expect(fixed.hue, dark.hue);
    expect(fixed.saturation, dark.saturation);
    expect(fixed.value, greaterThan(dark.value));
  });

  test('makeReadable desaturates when brightness is not enough', () {
    final blue = HSVColor.fromAHSV(1, 240, 1, 1);
    final fixed = AccentColor.makeReadable(blue);
    expect(AccentColor.isReadable(fixed.toColor()), isTrue);
    expect(fixed.hue, blue.hue);
    expect(fixed.saturation, lessThan(1));
  });

  test('minReadableValue is null where no brightness is readable', () {
    expect(AccentColor.minReadableValue(240, 1), isNull);
    final value = AccentColor.minReadableValue(120, 1)!;
    expect(
      AccentColor.isReadable(HSVColor.fromAHSV(1, 120, 1, value).toColor()),
      isTrue,
    );
  });

  test('the pressed state is darker', () {
    final pressed = AccentColor.pressed(AppTokens.dark.accent);
    expect(
      pressed.computeLuminance(),
      lessThan(AppTokens.dark.accent.computeLuminance()),
    );
  });

  test('hex round trip', () {
    expect(AccentColor.toHex(0xFF28DE4B), '#28DE4B');
    expect(AccentColor.fromHex('#28de4b'), 0xFF28DE4B);
    expect(AccentColor.fromHex('28DE4B'), isNull);
    expect(AccentColor.fromHex('#28DE4'), isNull);
    expect(AccentColor.fromHex(null), isNull);
  });
}
