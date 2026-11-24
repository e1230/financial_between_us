/// Why a field of an auth form is invalid. The presentation layer maps each
/// failure to its user-facing message.
sealed class FieldFailure {
  const FieldFailure();
}

/// The field is empty.
final class FieldRequired extends FieldFailure {
  const FieldRequired();
}

/// The username does not match [AuthValidators.usernamePattern].
final class UsernameInvalid extends FieldFailure {
  const UsernameInvalid();
}

/// The email is not well formed.
final class EmailInvalid extends FieldFailure {
  const EmailInvalid();
}

/// The password is shorter than [AuthValidators.minPasswordLength].
final class PasswordTooShort extends FieldFailure {
  const PasswordTooShort(this.missing);

  /// How many characters are missing to reach the minimum.
  final int missing;

  @override
  bool operator ==(Object other) =>
      other is PasswordTooShort && other.missing == missing;

  @override
  int get hashCode => missing.hashCode;
}

/// Client-side validation rules of the auth forms. Each method returns
/// `null` when the value is valid.
abstract final class AuthValidators {
  /// Lowercase letters, digits, dot or underscore; 3 to 20 characters.
  static final RegExp usernamePattern = RegExp(r'^[a-z0-9_.]{3,20}$');

  /// Pragmatic email check: something@something.tld, no spaces.
  static final RegExp emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static const int minPasswordLength = 8;

  static FieldFailure? username(String value) {
    final username = value.trim();
    if (username.isEmpty) return const FieldRequired();
    if (!usernamePattern.hasMatch(username)) return const UsernameInvalid();
    return null;
  }

  static FieldFailure? email(String value) {
    final email = value.trim();
    if (email.isEmpty) return const FieldRequired();
    if (!emailPattern.hasMatch(email)) return const EmailInvalid();
    return null;
  }

  /// Password of a new account (sign-up or password reset).
  static FieldFailure? newPassword(String value) {
    if (value.length >= minPasswordLength) return null;
    return PasswordTooShort(minPasswordLength - value.length);
  }

  /// Any non-empty value (login identifier and password).
  static FieldFailure? required(String value) =>
      value.trim().isEmpty ? const FieldRequired() : null;
}
