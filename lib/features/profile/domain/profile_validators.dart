/// Why a field of the profile form is invalid.
sealed class ProfileFieldFailure {
  const ProfileFieldFailure();
}

/// The display name is longer than [ProfileValidators.maxDisplayNameLength].
final class DisplayNameTooLong extends ProfileFieldFailure {
  const DisplayNameTooLong();
}

/// Client-side validation of the profile form. `null` means valid.
abstract final class ProfileValidators {
  static const int maxDisplayNameLength = 40;

  /// Optional: empty keeps the current name.
  static ProfileFieldFailure? displayName(String value) =>
      value.trim().length > maxDisplayNameLength
      ? const DisplayNameTooLong()
      : null;
}
