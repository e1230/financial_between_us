import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';

import '../../profile/data/user_profile_repository.dart';
import '../domain/auth_failure.dart';

/// Converts Firebase errors into [AuthFailure]s.
abstract final class AuthErrorMapper {
  static AuthFailure map(Object error, [StackTrace? stackTrace]) {
    if (error is AuthFailure) return error;
    if (error is NicknameTakenException) return const NicknameTaken();
    if (error is FirebaseException) {
      final failure = fromCode(error.code);
      if (failure is UnknownAuthFailure) _log(error, stackTrace);
      return failure;
    }
    _log(error, stackTrace);
    return const UnknownAuthFailure();
  }

  /// Firebase Auth and Firestore error codes.
  static AuthFailure fromCode(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'invalid-email' ||
    'user-disabled' ||
    // Only after a failed re-authentication (changing the password).
    'requires-recent-login' => const InvalidCredentials(),
    'email-already-in-use' => const EmailAlreadyInUse(),
    'weak-password' => const WeakPassword(),
    'too-many-requests' => const TooManyRequests(),
    // Firestore reports a missing connection as `unavailable`.
    'network-request-failed' || 'unavailable' => const NetworkFailure(),
    'account-exists-with-different-credential' =>
      const AccountExistsWithDifferentCredential(),
    _ => UnknownAuthFailure(code),
  };

  static void _log(Object error, StackTrace? stackTrace) => developer.log(
    'Unexpected auth error',
    name: 'fbu.auth',
    error: error,
    stackTrace: stackTrace,
  );
}
