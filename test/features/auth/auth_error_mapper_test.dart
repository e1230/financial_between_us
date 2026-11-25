import 'package:financial_between_us/features/auth/data/auth_error_mapper.dart';
import 'package:financial_between_us/features/auth/domain/auth_failure.dart';
import 'package:financial_between_us/features/profile/data/user_profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wrong credentials of any kind map to the same failure', () {
    for (final code in [
      'invalid-credential',
      'wrong-password',
      'user-not-found',
      'invalid-email',
    ]) {
      expect(AuthErrorMapper.fromCode(code), isA<InvalidCredentials>());
    }
  });

  test('maps the codes of the handoff table', () {
    expect(
      AuthErrorMapper.fromCode('email-already-in-use'),
      isA<EmailAlreadyInUse>(),
    );
    expect(AuthErrorMapper.fromCode('weak-password'), isA<WeakPassword>());
    expect(
      AuthErrorMapper.fromCode('too-many-requests'),
      isA<TooManyRequests>(),
    );
    expect(
      AuthErrorMapper.fromCode('network-request-failed'),
      isA<NetworkFailure>(),
    );
    expect(AuthErrorMapper.fromCode('unavailable'), isA<NetworkFailure>());
    expect(
      AuthErrorMapper.fromCode('account-exists-with-different-credential'),
      isA<AccountExistsWithDifferentCredential>(),
    );
    expect(
      AuthErrorMapper.fromCode('something-new'),
      isA<UnknownAuthFailure>().having((f) => f.code, 'code', 'something-new'),
    );
  });

  test('maps exceptions', () {
    expect(
      AuthErrorMapper.map(FirebaseAuthException(code: 'weak-password')),
      isA<WeakPassword>(),
    );
    expect(
      AuthErrorMapper.map(const NicknameTakenException()),
      isA<NicknameTaken>(),
    );
    expect(
      AuthErrorMapper.map(const TooManyRequests()),
      isA<TooManyRequests>(),
    );
    expect(AuthErrorMapper.map(StateError('x')), isA<UnknownAuthFailure>());
  });
}
