import 'package:material_ui/material_ui.dart';

/// Colors derived from the signed-in user's color (`users/{uid}.color`).
///
/// It lives in the [ThemeData], so when the user changes their color the
/// app theme animation interpolates every widget that reads it.
@immutable
class UserPalette extends ThemeExtension<UserPalette> {
  const UserPalette({
    required this.userColor,
    required this.userTint,
    required this.userSoft,
  });

  /// Palette of [color]: [userTint] is [color] at 20 % and [userSoft] is
  /// [color] mixed with white at 35 % (`c + (255 − c) × 0.35` per channel).
  factory UserPalette.fromColor(Color color) {
    final opaque = color.withValues(alpha: 1);
    return UserPalette(
      userColor: opaque,
      userTint: opaque.withValues(alpha: tintOpacity),
      userSoft: Color.lerp(opaque, const Color(0xFFFFFFFF), softWhiteMix)!,
    );
  }

  /// Opacity of [userTint].
  static const double tintOpacity = 0.20;

  /// How much white goes into [userSoft].
  static const double softWhiteMix = 0.35;

  /// The color the user chose: avatar, center of the Home arc, + button.
  final Color userColor;

  /// Backgrounds of icons and chips.
  final Color userTint;

  /// Icons and text on the dark background.
  final Color userSoft;

  @override
  UserPalette copyWith({Color? userColor, Color? userTint, Color? userSoft}) =>
      UserPalette(
        userColor: userColor ?? this.userColor,
        userTint: userTint ?? this.userTint,
        userSoft: userSoft ?? this.userSoft,
      );

  @override
  UserPalette lerp(covariant UserPalette? other, double t) {
    if (other == null) return this;
    return UserPalette(
      userColor: Color.lerp(userColor, other.userColor, t)!,
      userTint: Color.lerp(userTint, other.userTint, t)!,
      userSoft: Color.lerp(userSoft, other.userSoft, t)!,
    );
  }
}

extension UserPaletteContext on BuildContext {
  /// Palette of the signed-in user's color.
  UserPalette get userPalette =>
      Theme.of(this).extension<UserPalette>() ??
      UserPalette.fromColor(Theme.of(this).colorScheme.primary);
}
