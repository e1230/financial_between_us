import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/theme/app_tokens.dart';
import 'package:financial_between_us/core/theme/user_palette.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('tint is the color at 20 % and soft mixes 35 % of white', () {
    final palette = UserPalette.fromColor(const Color(0xFF6C63FF));
    expect(palette.userTint, const Color(0xFF6C63FF).withValues(alpha: 0.2));
    // 0x6C + (255 − 0x6C) × 0.35 ≈ 159, 0x63 → 154, 0xFF → 255.
    expect((palette.userSoft.r * 255).round(), 159);
    expect((palette.userSoft.g * 255).round(), 154);
    expect((palette.userSoft.b * 255).round(), 255);
  });

  test('lerp interpolates every color', () {
    final from = UserPalette.fromColor(const Color(0xFF000000));
    final to = UserPalette.fromColor(const Color(0xFFFFFFFF));
    final mid = from.lerp(to, 0.5);
    expect((mid.userColor.r * 255).round(), closeTo(128, 1));
  });

  test('the theme carries the palette of the accent; positive stays green', () {
    const orange = Color(0xFFFF8A65);
    final theme = AppTheme.withAccent(orange);
    expect(theme.extension<UserPalette>()!.userColor, orange);
    final tokens = theme.extension<AppTokens>()!;
    expect(tokens.accent, orange);
    expect(tokens.positive, const Color(0xFF28DE4B));
  });
}
