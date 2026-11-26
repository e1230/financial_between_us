/// How the signed-in user authenticates.
enum SignInMethod {
  /// Email (or nickname) and password: the password can be changed.
  password,

  /// Google account: the password is managed by Google.
  google,
}

/// Firebase Auth provider ids.
abstract final class AuthProviderIds {
  static const String password = 'password';
  static const String google = 'google.com';
}

/// Sign-in method of an account with the given Firebase [providerIds], or
/// `null` if none is known. An account that has a password wins over Google,
/// because that password can still be changed.
SignInMethod? signInMethodFor(Iterable<String> providerIds) {
  final ids = providerIds.toSet();
  if (ids.contains(AuthProviderIds.password)) return SignInMethod.password;
  if (ids.contains(AuthProviderIds.google)) return SignInMethod.google;
  return null;
}
