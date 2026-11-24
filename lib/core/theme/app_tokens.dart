import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

/// Design tokens for Financial Between Us.
///
/// Every color, spacing, radius, duration and font family used by widgets
/// must come from here (via `context.tokens`) or from the [ThemeData].
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.accent,
    required this.accentPressed,
    required this.onAccent,
    required this.negative,
    required this.warning,
    required this.progressTrack,
    required this.iconMuted,
    required this.glowBright,
    required this.glowMid,
    required this.glowDeep,
    required this.glowTeal,
    required this.brandBackground,
    required this.brandCoin,
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space5,
    required this.space6,
    required this.radiusCard,
    required this.radiusInput,
    required this.radiusPill,
    required this.motionFast,
    required this.motionShort,
    required this.motionMedium,
    required this.headingFontFamily,
    required this.bodyFontFamily,
    required this.brandFontFamily,
  });

  /// The only theme of the app (dark, Revolut-like).
  static const AppTokens dark = AppTokens(
    background: Color(0xFF111111),
    surface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFF242424),
    border: Color(0xFF2E2E2E),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0x99F2F2F2), // 60 %
    textDisabled: Color(0x61F2F2F2), // 38 %
    accent: Color(0xFF28DE4B),
    accentPressed: Color(0xFF22C443),
    onAccent: Color(0xFF111111),
    negative: Color(0xFFFF5A5F),
    warning: Color(0xFFFFB020),
    progressTrack: Color(0x3DF2F2F2), // 24 %
    iconMuted: Color(0xFF9A9A9A),
    glowBright: Color(0xFF1E9E3A),
    glowMid: Color(0xFF0E4F22),
    glowDeep: Color(0xFF0A2814),
    glowTeal: Color(0xFF0F3D3A),
    brandBackground: Color(0xFF000000),
    brandCoin: Color(0xFF0A0A0A),
    space1: 8,
    space2: 16,
    space3: 24,
    space4: 32,
    space5: 40,
    space6: 48,
    radiusCard: 12,
    radiusInput: 12,
    radiusPill: 999,
    motionFast: Duration(milliseconds: 150),
    motionShort: Duration(milliseconds: 200),
    motionMedium: Duration(milliseconds: 400),
    headingFontFamily: 'Satoshi',
    bodyFontFamily: 'Inter',
    brandFontFamily: 'SpaceGrotesk',
  );

  // Colors
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color accent;

  /// [accent] while a primary button is pressed.
  final Color accentPressed;

  /// Text and icons on top of [accent]. Always `#111111`.
  final Color onAccent;
  final Color negative;
  final Color warning;

  /// Unfilled track of progress bars.
  final Color progressTrack;

  /// Inactive utility icons (e.g. the password eye).
  final Color iconMuted;

  // Animated auth background (radial glows over [background]).
  final Color glowBright;
  final Color glowMid;
  final Color glowDeep;
  final Color glowTeal;

  /// Pure black used by the native and animated splash.
  final Color brandBackground;

  /// Fill of the coin in the logo emblem.
  final Color brandCoin;

  // Spacing (multiples of 8)
  final double space1;
  final double space2;
  final double space3;
  final double space4;
  final double space5;
  final double space6;

  // Radii
  final double radiusCard;
  final double radiusInput;
  final double radiusPill;

  // Motion
  final Duration motionFast;
  final Duration motionShort;
  final Duration motionMedium;

  // Typography
  final String headingFontFamily;
  final String bodyFontFamily;

  /// Brand typeface, only for the logo (emblem rim text and wordmark).
  final String brandFontFamily;

  @override
  AppTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? accent,
    Color? accentPressed,
    Color? onAccent,
    Color? negative,
    Color? warning,
    Color? progressTrack,
    Color? iconMuted,
    Color? glowBright,
    Color? glowMid,
    Color? glowDeep,
    Color? glowTeal,
    Color? brandBackground,
    Color? brandCoin,
    double? space1,
    double? space2,
    double? space3,
    double? space4,
    double? space5,
    double? space6,
    double? radiusCard,
    double? radiusInput,
    double? radiusPill,
    Duration? motionFast,
    Duration? motionShort,
    Duration? motionMedium,
    String? headingFontFamily,
    String? bodyFontFamily,
    String? brandFontFamily,
  }) {
    return AppTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      onAccent: onAccent ?? this.onAccent,
      negative: negative ?? this.negative,
      warning: warning ?? this.warning,
      progressTrack: progressTrack ?? this.progressTrack,
      iconMuted: iconMuted ?? this.iconMuted,
      glowBright: glowBright ?? this.glowBright,
      glowMid: glowMid ?? this.glowMid,
      glowDeep: glowDeep ?? this.glowDeep,
      glowTeal: glowTeal ?? this.glowTeal,
      brandBackground: brandBackground ?? this.brandBackground,
      brandCoin: brandCoin ?? this.brandCoin,
      space1: space1 ?? this.space1,
      space2: space2 ?? this.space2,
      space3: space3 ?? this.space3,
      space4: space4 ?? this.space4,
      space5: space5 ?? this.space5,
      space6: space6 ?? this.space6,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusInput: radiusInput ?? this.radiusInput,
      radiusPill: radiusPill ?? this.radiusPill,
      motionFast: motionFast ?? this.motionFast,
      motionShort: motionShort ?? this.motionShort,
      motionMedium: motionMedium ?? this.motionMedium,
      headingFontFamily: headingFontFamily ?? this.headingFontFamily,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
      brandFontFamily: brandFontFamily ?? this.brandFontFamily,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    double d(double a, double b) => lerpDouble(a, b, t)!;
    final pick = t < 0.5 ? this : other;
    return AppTokens(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceVariant: c(surfaceVariant, other.surfaceVariant),
      border: c(border, other.border),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textDisabled: c(textDisabled, other.textDisabled),
      accent: c(accent, other.accent),
      accentPressed: c(accentPressed, other.accentPressed),
      onAccent: c(onAccent, other.onAccent),
      negative: c(negative, other.negative),
      warning: c(warning, other.warning),
      progressTrack: c(progressTrack, other.progressTrack),
      iconMuted: c(iconMuted, other.iconMuted),
      glowBright: c(glowBright, other.glowBright),
      glowMid: c(glowMid, other.glowMid),
      glowDeep: c(glowDeep, other.glowDeep),
      glowTeal: c(glowTeal, other.glowTeal),
      brandBackground: c(brandBackground, other.brandBackground),
      brandCoin: c(brandCoin, other.brandCoin),
      space1: d(space1, other.space1),
      space2: d(space2, other.space2),
      space3: d(space3, other.space3),
      space4: d(space4, other.space4),
      space5: d(space5, other.space5),
      space6: d(space6, other.space6),
      radiusCard: d(radiusCard, other.radiusCard),
      radiusInput: d(radiusInput, other.radiusInput),
      radiusPill: d(radiusPill, other.radiusPill),
      motionFast: pick.motionFast,
      motionShort: pick.motionShort,
      motionMedium: pick.motionMedium,
      headingFontFamily: pick.headingFontFamily,
      bodyFontFamily: pick.bodyFontFamily,
      brandFontFamily: pick.brandFontFamily,
    );
  }
}

extension AppTokensContext on BuildContext {
  /// Design tokens of the current theme.
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.dark;
}
