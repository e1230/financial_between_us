import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted SHA-256 of group passwords. The password itself is never stored.
// TODO: seguridad. SHA-256 is fast, so a leaked hash can be brute-forced.
// The hash is unreadable by the app (security rules), but the safer option
// is a `joinGroup` Cloud Function with bcrypt or scrypt (Blaze plan).
class GroupPasswordHasher {
  GroupPasswordHasher([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  static const int saltBytes = 16;

  /// A new random salt (URL-safe base64).
  String newSalt() => base64Url.encode(
    List<int>.generate(saltBytes, (_) => _random.nextInt(256)),
  );

  /// Hex SHA-256 of [salt] and [password].
  String hash({required String salt, required String password}) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();
}
