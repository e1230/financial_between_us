import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// Profile of a user (`users/{uid}` in Firestore).
///
/// Pure domain entity: dates are [DateTime] and the color an opaque ARGB
/// integer; the data layer converts them to Firestore types.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,

    /// Visible name ("Mauricio Beltrán"). Defaults to the nickname.
    required String displayName,

    /// How the group calls the user ("mao"). Unique, lowercase, also the
    /// username used to sign in. It does not change.
    required String nickname,

    /// Copy of the Firebase Auth email.
    required String email,

    /// Cloudinary `secure_url` of the avatar. Without it the avatar is the
    /// first letter over [colorValue].
    String? photoUrl,

    /// Accent color of the user, opaque ARGB (`0xFFRRGGBB`).
    @Default(UserProfile.defaultColorValue) int colorValue,

    /// Whether the user went through "Completa tu perfil" after signing up.
    @Default(false) bool profileCompleted,

    /// Set by the server; `null` while a local write is pending.
    DateTime? createdAt,
    DateTime? updatedAt,

    /// Soft delete: nothing is physically deleted.
    DateTime? deletedAt,
  }) = _UserProfile;

  const UserProfile._();

  /// `#28DE4B`, the brand accent.
  static const int defaultColorValue = 0xFF28DE4B;

  /// Letter of the fallback avatar.
  String get initial {
    final source = displayName.trim().isNotEmpty ? displayName : nickname;
    final trimmed = source.trim();
    return trimmed.isEmpty
        ? '?'
        : String.fromCharCode(trimmed.runes.first).toUpperCase();
  }
}
