import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/auth/domain/auth_failure.dart';
import 'package:financial_between_us/features/auth/domain/session_destination.dart';
import 'package:financial_between_us/features/profile/data/user_profile_repository.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../support/fakes.dart';

void main() {
  late FakeFirebaseAuth auth;
  late FakeGoogleSignIn google;
  late FakeNicknameRepository nicknames;
  late FakeUserProfileRepository profiles;
  late FirebaseAuthRepository repository;

  setUp(() {
    auth = FakeFirebaseAuth(passwords: {'juan@correo.com': 'cuentasclaras'});
    google = FakeGoogleSignIn();
    nicknames = FakeNicknameRepository({'juanes_92': 'juan@correo.com'});
    profiles = FakeUserProfileRepository(nicknames: nicknames);
    repository = FirebaseAuthRepository(
      auth: auth,
      google: google,
      nicknames: nicknames,
      profiles: profiles,
    );
  });

  void completeProfileOf(String uid) => profiles.profiles[uid] = UserProfile(
    uid: uid,
    displayName: 'Juan',
    nickname: 'juanes_92',
    email: 'juan@correo.com',
    profileCompleted: true,
  );

  group('signIn', () {
    test('with an email', () async {
      completeProfileOf('uid-juan@correo.com');
      final destination = await repository.signIn(
        identifier: ' juan@correo.com ',
        password: 'cuentasclaras',
      );
      expect(destination, SessionDestination.home);
    });

    test('with a nickname, in any case', () async {
      completeProfileOf('uid-juan@correo.com');
      final destination = await repository.signIn(
        identifier: 'JuanEs_92',
        password: 'cuentasclaras',
      );
      expect(destination, SessionDestination.home);
    });

    test('an unknown nickname fails like a wrong password', () async {
      await expectLater(
        repository.signIn(identifier: 'nadie', password: 'cuentasclaras'),
        throwsA(isA<InvalidCredentials>()),
      );
      await expectLater(
        repository.signIn(identifier: 'juanes_92', password: 'otra-clave'),
        throwsA(isA<InvalidCredentials>()),
      );
    });

    test('sends a user without users/{uid} to choose a nickname', () async {
      final destination = await repository.signIn(
        identifier: 'juan@correo.com',
        password: 'cuentasclaras',
      );
      expect(destination, SessionDestination.chooseNickname);
    });

    test('maps network errors', () async {
      auth.error = FirebaseAuthException(code: 'network-request-failed');
      await expectLater(
        repository.signIn(identifier: 'a@b.co', password: 'x'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('register', () {
    test(
      'creates the account, reserves the nickname and the profile',
      () async {
        final destination = await repository.register(
          nickname: 'Mao',
          email: 'mao@correo.com',
          password: 'cuentasclaras',
        );

        expect(destination, SessionDestination.completeProfile);
        expect(nicknames.emails['mao'], 'mao@correo.com');
        final profile = profiles.profiles[auth.nextUser.uid]!;
        expect(profile.nickname, 'mao');
        expect(profile.displayName, 'mao');
        expect(profile.profileCompleted, isFalse);
        expect(auth.nextUser.displayName, 'mao');
      },
    );

    test('a taken nickname fails before creating the account', () async {
      await expectLater(
        repository.register(
          nickname: 'juanes_92',
          email: 'otro@correo.com',
          password: 'cuentasclaras',
        ),
        throwsA(isA<NicknameTaken>()),
      );
      expect(auth.passwords.containsKey('otro@correo.com'), isFalse);
    });

    test('any failure creating the profile deletes the new account', () async {
      profiles.createError = const _ProfileWriteError();
      await expectLater(
        repository.register(
          nickname: 'mao',
          email: 'mao@correo.com',
          password: 'cuentasclaras',
        ),
        throwsA(isA<UnknownAuthFailure>()),
      );
      expect(auth.nextUser.deleted, isTrue);
    });

    test('a taken nickname in the transaction is reported as such', () async {
      // Someone reserves it between the check and the transaction.
      profiles.createError = const NicknameTakenException();
      await expectLater(
        repository.register(
          nickname: 'mao',
          email: 'mao@correo.com',
          password: 'cuentasclaras',
        ),
        throwsA(isA<NicknameTaken>()),
      );
      expect(auth.nextUser.deleted, isTrue);
    });

    test('an email in use is reported', () async {
      await expectLater(
        repository.register(
          nickname: 'mao',
          email: 'juan@correo.com',
          password: 'cuentasclaras',
        ),
        throwsA(isA<EmailAlreadyInUse>()),
      );
    });
  });

  group('Google', () {
    test('closing the dialog is not an error', () async {
      google.error = const GoogleSignInException(
        code: GoogleSignInExceptionCode.canceled,
      );
      expect(await repository.signInWithGoogle(), isNull);
    });

    test('the first time asks for a nickname', () async {
      expect(
        await repository.signInWithGoogle(),
        SessionDestination.chooseNickname,
      );
    });

    test('initializes google_sign_in only once', () async {
      await repository.signInWithGoogle();
      await repository.signInWithGoogle();
      expect(google.initializeCalls, 1);
    });

    test('claimNickname uses the Google name as display name', () async {
      auth
        ..nextUser = FakeUser(
          uid: 'g1',
          email: 'ana@gmail.com',
          displayName: 'Ana María',
        )
        ..currentUser = auth.nextUser;

      final destination = await repository.claimNickname('Ana');

      expect(destination, SessionDestination.completeProfile);
      final profile = profiles.profiles['g1']!;
      expect(profile.nickname, 'ana');
      expect(profile.displayName, 'Ana María');
      expect(profile.email, 'ana@gmail.com');
    });
  });

  test('claimNickname twice does not reserve a second nickname', () async {
    auth
      ..nextUser = FakeUser(uid: 'g1', email: 'ana@gmail.com')
      ..currentUser = auth.nextUser;

    await repository.claimNickname('ana');
    final again = await repository.claimNickname('ana_2');

    expect(again, SessionDestination.completeProfile);
    expect(nicknames.emails.containsKey('ana_2'), isFalse);
    expect(profiles.profiles['g1']!.nickname, 'ana');
  });

  group('sendPasswordReset', () {
    test('sends the email in Spanish', () async {
      await repository.sendPasswordReset(' juan@correo.com ');
      expect(auth.resetEmails, ['juan@correo.com']);
      expect(auth.emailLanguage, 'es');
    });

    test('does not reveal unknown emails', () async {
      auth.error = FirebaseAuthException(code: 'user-not-found');
      await repository.sendPasswordReset('nadie@correo.com');
    });

    test('reports network errors', () async {
      auth.error = FirebaseAuthException(code: 'network-request-failed');
      await expectLater(
        repository.sendPasswordReset('juan@correo.com'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('changePassword', () {
    late FakeUser user;

    setUp(() => auth.currentUser = user = FakeUser());

    test('re-authenticates and sets the new password', () async {
      await repository.changePassword(
        currentPassword: 'cuentasclaras',
        newPassword: 'nuevaclave',
      );
      expect(user.reauthenticated, isTrue);
      expect(user.password, 'nuevaclave');
    });

    test('a wrong current password fails as invalid credentials', () async {
      await expectLater(
        repository.changePassword(
          currentPassword: 'otra-clave',
          newPassword: 'nuevaclave',
        ),
        throwsA(isA<InvalidCredentials>()),
      );
      expect(user.password, 'cuentasclaras');
    });

    test('maps a weak password', () async {
      user.updatePasswordError = FirebaseAuthException(code: 'weak-password');
      await expectLater(
        repository.changePassword(
          currentPassword: 'cuentasclaras',
          newPassword: 'nuevaclave',
        ),
        throwsA(isA<WeakPassword>()),
      );
    });

    test('fails without a session', () async {
      auth.currentUser = null;
      await expectLater(
        repository.changePassword(
          currentPassword: 'cuentasclaras',
          newPassword: 'nuevaclave',
        ),
        throwsA(isA<UnknownAuthFailure>()),
      );
    });
  });

  test('signOut signs out of Firebase and Google', () async {
    await repository.signOut();
    expect(auth.signedOut, isTrue);
    expect(google.signedOut, isTrue);
  });
}

/// Any unexpected error of the profile transaction.
class _ProfileWriteError implements Exception {
  const _ProfileWriteError();
}
