import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/accent_color.dart';
import '../domain/user_profile.dart';

/// Field names of `users/{uid}`.
abstract final class UserProfileFields {
  static const String displayName = 'displayName';
  static const String nickname = 'nickname';
  static const String email = 'email';
  static const String photoUrl = 'photoUrl';
  static const String color = 'color';
  static const String profileCompleted = 'profileCompleted';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String deletedAt = 'deletedAt';
}

/// Converts `users/{uid}` documents to [UserProfile] and back.
abstract final class UserProfileMapper {
  /// Reads a `users/{uid}` document. Missing or malformed optional values
  /// fall back to their defaults so an old document never crashes the app.
  static UserProfile fromFirestore(String uid, Map<String, dynamic> data) {
    final nickname = data[UserProfileFields.nickname] as String? ?? '';
    final displayName = data[UserProfileFields.displayName] as String?;
    return UserProfile(
      uid: uid,
      nickname: nickname,
      displayName: (displayName == null || displayName.trim().isEmpty)
          ? nickname
          : displayName,
      email: data[UserProfileFields.email] as String? ?? '',
      photoUrl: data[UserProfileFields.photoUrl] as String?,
      colorValue:
          AccentColor.fromHex(data[UserProfileFields.color] as String?) ??
          UserProfile.defaultColorValue,
      profileCompleted:
          data[UserProfileFields.profileCompleted] as bool? ?? false,
      createdAt: _date(data[UserProfileFields.createdAt]),
      updatedAt: _date(data[UserProfileFields.updatedAt]),
      deletedAt: _date(data[UserProfileFields.deletedAt]),
    );
  }

  /// Document of a new user, with server timestamps.
  static Map<String, Object?> newUser({
    required String nickname,
    required String email,
    required String displayName,
  }) => {
    UserProfileFields.displayName: displayName,
    UserProfileFields.nickname: nickname,
    UserProfileFields.email: email,
    UserProfileFields.photoUrl: null,
    UserProfileFields.color: AccentColor.toHex(UserProfile.defaultColorValue),
    UserProfileFields.profileCompleted: false,
    UserProfileFields.createdAt: FieldValue.serverTimestamp(),
    UserProfileFields.updatedAt: FieldValue.serverTimestamp(),
    UserProfileFields.deletedAt: null,
  };

  /// Fields written when the user finishes "Completa tu perfil".
  static Map<String, Object?> completion({
    required String displayName,
    required String? photoUrl,
    required int colorValue,
  }) => {
    UserProfileFields.displayName: displayName,
    UserProfileFields.photoUrl: photoUrl,
    UserProfileFields.color: AccentColor.toHex(colorValue),
    UserProfileFields.profileCompleted: true,
    UserProfileFields.updatedAt: FieldValue.serverTimestamp(),
  };

  static DateTime? _date(Object? value) =>
      value is Timestamp ? value.toDate() : null;
}
