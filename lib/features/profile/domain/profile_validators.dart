import '../../auth/domain/auth_validators.dart';

/// Why a field of the profile form is invalid.
sealed class ProfileFieldFailure {
  const ProfileFieldFailure();
}

/// The display name is longer than [ProfileValidators.maxDisplayNameLength].
final class DisplayNameTooLong extends ProfileFieldFailure {
  const DisplayNameTooLong();
}

/// The current password is empty.
final class CurrentPasswordRequired extends ProfileFieldFailure {
  const CurrentPasswordRequired();
}

/// The new password is shorter than [AuthValidators.minPasswordLength].
final class NewPasswordTooShort extends ProfileFieldFailure {
  const NewPasswordTooShort();
}

/// The new password is the same as the current one.
final class SameAsCurrentPassword extends ProfileFieldFailure {
  const SameAsCurrentPassword();
}

/// The confirmation does not match the new password.
final class PasswordsDoNotMatch extends ProfileFieldFailure {
  const PasswordsDoNotMatch();
}

/// Client-side validation of the profile forms. `null` means valid.
abstract final class ProfileValidators {
  static const int maxDisplayNameLength = 40;

  /// Optional: empty keeps the current name.
  static ProfileFieldFailure? displayName(String value) =>
      value.trim().length > maxDisplayNameLength
      ? const DisplayNameTooLong()
      : null;

  /// Current password of "Cambiar contraseña".
  static ProfileFieldFailure? currentPassword(String value) =>
      value.isEmpty ? const CurrentPasswordRequired() : null;

  /// New password of "Cambiar contraseña": long enough and different from
  /// [current].
  static ProfileFieldFailure? newPassword(
    String value, {
    required String current,
  }) {
    if (AuthValidators.newPassword(value) != null) {
      return const NewPasswordTooShort();
    }
    if (value == current) return const SameAsCurrentPassword();
    return null;
  }

  /// Confirmation of the new password.
  static ProfileFieldFailure? confirmPassword(
    String value, {
    required String newPassword,
  }) => value == newPassword ? null : const PasswordsDoNotMatch();
}
