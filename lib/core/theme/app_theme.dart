import 'package:material_ui/material_ui.dart';

import '../utils/accent_color.dart';
import 'app_tokens.dart';

/// Builds the app [ThemeData] from [AppTokens].
abstract final class AppTheme {
  static ThemeData get dark => _build(AppTokens.dark);

  /// [dark] with the accent color chosen by the user in their profile. The
  /// base tokens do not change; only [AppTokens.accent] and
  /// [AppTokens.accentPressed] are replaced.
  static ThemeData withAccent(Color accent) {
    if (accent == AppTokens.dark.accent) return dark;
    return _build(
      AppTokens.dark.copyWith(
        accent: accent,
        accentPressed: AccentColor.pressed(accent),
      ),
    );
  }

  static ThemeData _build(AppTokens t) {
    final colorScheme = ColorScheme.dark(
      primary: t.accent,
      onPrimary: t.onAccent,
      secondary: t.accent,
      onSecondary: t.onAccent,
      surface: t.background,
      onSurface: t.textPrimary,
      surfaceContainerLow: t.surface,
      surfaceContainer: t.surface,
      surfaceContainerHighest: t.surfaceVariant,
      onSurfaceVariant: t.textSecondary,
      outline: t.border,
      outlineVariant: t.border,
      error: t.negative,
      onError: t.onAccent,
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radiusCard),
      side: BorderSide(color: t.border),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.radiusInput),
      borderSide: BorderSide(color: t.border),
    );
    final pillShape = WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(t.radiusPill)),
    );
    final buttonPadding = WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: t.space3, vertical: t.space2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: t.background,
      canvasColor: t.background,
      dividerColor: t.border,
      fontFamily: t.bodyFontFamily,
      textTheme: _textTheme(t),
      extensions: <ThemeExtension<dynamic>>[t],
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surfaceVariant,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: t.accent),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: t.negative),
        ),
        hintStyle: TextStyle(color: t.textDisabled),
        labelStyle: TextStyle(color: t.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surfaceVariant,
        side: BorderSide(color: t.border),
        shape: StadiumBorder(side: BorderSide(color: t.border)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? t.surfaceVariant
                : t.accent,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? t.textDisabled
                : t.onAccent,
          ),
          shape: pillShape,
          padding: buttonPadding,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(t.textPrimary),
          side: WidgetStatePropertyAll(BorderSide(color: t.border)),
          shape: pillShape,
          padding: buttonPadding,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(t.accent),
          shape: pillShape,
        ),
      ),
    );
  }

  /// Satoshi for headings, Inter (tabular figures) for body and amounts.
  static TextTheme _textTheme(AppTokens t) {
    TextStyle heading(double size, FontWeight weight) => TextStyle(
      fontFamily: t.headingFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: t.textPrimary,
      height: 1.2,
    );
    TextStyle body(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: t.bodyFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.4,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return TextTheme(
      displayLarge: heading(48, FontWeight.w700),
      displayMedium: heading(40, FontWeight.w700),
      displaySmall: heading(32, FontWeight.w700),
      headlineLarge: heading(28, FontWeight.w700),
      headlineMedium: heading(24, FontWeight.w700),
      headlineSmall: heading(20, FontWeight.w700),
      titleLarge: heading(20, FontWeight.w600),
      titleMedium: body(16, FontWeight.w600, t.textPrimary),
      titleSmall: body(14, FontWeight.w600, t.textPrimary),
      bodyLarge: body(16, FontWeight.w400, t.textPrimary),
      bodyMedium: body(14, FontWeight.w400, t.textPrimary),
      bodySmall: body(12, FontWeight.w400, t.textSecondary),
      labelLarge: body(16, FontWeight.w600, t.textPrimary),
      labelMedium: body(14, FontWeight.w500, t.textSecondary),
      labelSmall: body(12, FontWeight.w500, t.textSecondary),
    );
  }
}
