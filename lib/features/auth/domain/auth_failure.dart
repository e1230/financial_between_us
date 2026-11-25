/// Why an auth or account request failed. The presentation layer maps each
/// case to its message and decides where to show it (field or banner).
sealed class AuthFailure implements Exception {
  const AuthFailure();
}

/// Wrong password, unknown email or unknown nickname. Deliberately the same
/// failure for all of them, so nobody can find out which accounts exist.
final class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();
}

/// Sign-up with an email that already has an account.
final class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse();
}

/// Firebase rejected the password as too weak.
final class WeakPassword extends AuthFailure {
  const WeakPassword();
}

/// The nickname is already reserved by someone else.
final class NicknameTaken extends AuthFailure {
  const NicknameTaken();
}

/// Too many attempts: Firebase is throttling this device.
final class TooManyRequests extends AuthFailure {
  const TooManyRequests();
}

/// No connection.
final class NetworkFailure extends AuthFailure {
  const NetworkFailure();
}

/// Google sign-in with an email that already has a password account.
final class AccountExistsWithDifferentCredential extends AuthFailure {
  const AccountExistsWithDifferentCredential();
}

/// Anything else; [code] is kept for the logs.
final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([this.code]);

  final String? code;

  @override
  String toString() => 'UnknownAuthFailure($code)';
}
