import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Rules for a user-chosen accent color.
///
/// The accent is drawn behind `#111111` text (buttons, avatar initials) and
/// as text on the `#111111` background (links), so it must reach a WCAG
/// contrast ratio of [minContrast] against [AppTokens.onAccent] both ways.
abstract final class AccentColor {
  /// WCAG AA for normal text.
  static const double minContrast = 4.5;

  /// How much darker the pressed state of the accent is (HSL lightness).
  static const double pressedLightnessDrop = 0.05;

  /// Default accent of the app (`#28DE4B`).
  static Color get fallback => AppTokens.dark.accent;

  /// Quick picks of the profile color picker. All of them are readable.
  static const List<int> presets = [
    0xFF28DE4B, // green (brand)
    0xFF4FC3F7, // sky
    0xFF4DD0E1, // cyan
    0xFF9FA8DA, // lavender
    0xFFBA68C8, // violet
    0xFFF06292, // pink
    0xFFFF8A65, // coral
    0xFFFFB020, // amber
    0xFFFFD54F, // yellow
    0xFFAED581, // lime
  ];

  /// WCAG contrast ratio between [a] and [b] (1 to 21).
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final (hi, lo) = la > lb ? (la, lb) : (lb, la);
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Whether [color] is readable with [AppTokens.onAccent] on top of it.
  static bool isReadable(Color color) =>
      contrast(color.withValues(alpha: 1), AppTokens.dark.onAccent) >=
      minContrast;

  /// The closest readable color to [color] with the same hue: first raises
  /// the HSV value (brightness) and, if that is not enough, lowers the
  /// saturation.
  static HSVColor makeReadable(HSVColor color) {
    if (isReadable(color.toColor())) return color;
    final brightest = color.withValue(1);
    if (isReadable(brightest.toColor())) {
      return color.withValue(
        _search(color.value, 1, (v) => color.withValue(v)),
      );
    }
    return brightest.withSaturation(
      _search(color.saturation, 0, (s) => brightest.withSaturation(s)),
    );
  }

  /// Smallest HSV value that is readable at [hue] and [saturation], or
  /// `null` when no value is.
  static double? minReadableValue(double hue, double saturation) {
    final base = HSVColor.fromAHSV(1, hue, saturation, 1);
    if (!isReadable(base.toColor())) return null;
    return _search(0, 1, base.withValue);
  }

  /// Binary search between [from] (unreadable) and [to] (readable) for the
  /// first readable value.
  static double _search(double from, double to, HSVColor Function(double) at) {
    var bad = from;
    var good = to;
    for (var i = 0; i < 20; i++) {
      final mid = (bad + good) / 2;
      if (isReadable(at(mid).toColor())) {
        good = mid;
      } else {
        bad = mid;
      }
    }
    return good;
  }

  /// Pressed state of [accent], like `#28DE4B` → `#22C443`.
  static Color pressed(Color accent) {
    final hsl = HSLColor.fromColor(accent);
    return hsl
        .withLightness((hsl.lightness - pressedLightnessDrop).clamp(0.0, 1.0))
        .toColor();
  }

  /// `#RRGGBB` (uppercase) of an opaque ARGB [value].
  static String toHex(int value) =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// Opaque ARGB of `#RRGGBB`, or `null` if [hex] is malformed.
  static int? fromHex(String? hex) {
    if (hex == null) return null;
    final match = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(hex.trim());
    if (match == null) return null;
    return 0xFF000000 | int.parse(match.group(1)!, radix: 16);
  }
}
