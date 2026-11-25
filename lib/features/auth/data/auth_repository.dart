import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../profile/data/profile_providers.dart';
import '../../profile/data/user_profile_repository.dart';
import '../../profile/domain/profile_validators.dart';
import '../domain/auth_failure.dart';
import '../domain/session_destination.dart';
import 'auth_error_mapper.dart';
import 'auth_providers.dart';
import 'nickname_repository.dart';

part 'auth_repository.g.dart';

/// Sign-up, sign-in (email, nickname or Google), password reset and
/// sign-out. Every method throws an [AuthFailure] on error.
abstract interface class AuthRepository {
  /// Signs in with an email or a nickname ([identifier]) and a password.
  Future<SessionDestination> signIn({
    required String identifier,
    required String password,
  });

  /// Creates the account, reserves [nickname] and creates `users/{uid}`.
  /// If the reservation fails the new account is deleted again.
  Future<SessionDestination> register({
    required String nickname,
    required String email,
    required String password,
  });

  /// Google sign-in. Returns `null` when the user closes the Google dialog.
  Future<SessionDestination?> signInWithGoogle();

  /// Reserves [nickname] for the signed-in user (first Google sign-in) and
  /// creates `users/{uid}`.
  Future<SessionDestination> claimNickname(String nickname);

  /// Sends the reset email. Unknown emails are not reported, so nobody can
  /// find out which accounts exist: only network errors and throttling are.
  Future<void> sendPasswordReset(String email);

  /// Signs out of Firebase and Google.
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required this._auth,
    required this._google,
    required this._nicknames,
    required this._profiles,
  });

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  final NicknameRepository _nicknames;
  final UserProfileRepository _profiles;

  /// Language of the emails Firebase sends (password reset).
  static const String emailLanguage = 'es';

  Future<void>? _googleReady;

  /// google_sign_in 7.x must be initialized exactly once. On Android the
  /// server client id comes from `google-services.json`.
  Future<void> _ensureGoogle() => _googleReady ??= _google.initialize();

  /// Runs [action] and converts any error into an [AuthFailure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      throw AuthErrorMapper.map(error, stackTrace);
    }
  }

  Future<SessionDestination> _destinationFor(User user) async =>
      sessionDestinationFor(await _profiles.fetch(user.uid));

  @override
  Future<SessionDestination> signIn({
    required String identifier,
    required String password,
  }) => _guard(() async {
    final id = identifier.trim();
    final email = id.contains('@')
        ? id
        : await _nicknames.emailFor(id.toLowerCase());
    if (email == null) throw const InvalidCredentials();
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _destinationFor(credential.user!);
  });

  @override
  Future<SessionDestination> register({
    required String nickname,
    required String email,
    required String password,
  }) => _guard(() async {
    final name = nickname.trim().toLowerCase();
    final address = email.trim();
    // Early check, for a quick error before creating the account. The
    // transaction below is what really guarantees uniqueness.
    if (!await _nicknames.isAvailable(name)) throw const NicknameTaken();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: address,
      password: password,
    );
    final user = credential.user!;
    try {
      await _profiles.createWithNickname(
        uid: user.uid,
        nickname: name,
        email: address,
        displayName: name,
      );
    } catch (_) {
      // DECISIÓN: the account is deleted on any failure (not only a taken
      // nickname), so the user can simply try again with the same email.
      await _deleteQuietly(user);
      rethrow;
    }
    await _quietly(
      'update the display name',
      () => user.updateDisplayName(name),
    );
    return SessionDestination.completeProfile;
  });

  @override
  Future<SessionDestination?> signInWithGoogle() => _guard(() async {
    await _ensureGoogle();
    final GoogleSignInAccount account;
    try {
      account = await _google.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return null;
      throw UnknownAuthFailure('google-${error.code.name}');
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) throw const UnknownAuthFailure('google-no-id-token');
    final credential = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return _destinationFor(credential.user!);
  });

  @override
  Future<SessionDestination> claimNickname(String nickname) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const UnknownAuthFailure('no-session');
    // Already has a profile (e.g. a repeated submit): never create a second
    // one or reserve a second nickname.
    final existing = await _profiles.fetch(user.uid);
    if (existing != null) return sessionDestinationFor(existing);
    final name = nickname.trim().toLowerCase();
    if (!await _nicknames.isAvailable(name)) throw const NicknameTaken();
    var googleName = user.displayName?.trim() ?? '';
    if (googleName.length > ProfileValidators.maxDisplayNameLength) {
      googleName = googleName.substring(
        0,
        ProfileValidators.maxDisplayNameLength,
      );
    }
    await _profiles.createWithNickname(
      uid: user.uid,
      nickname: name,
      email: user.email ?? '',
      displayName: googleName.isEmpty ? name : googleName,
    );
    return SessionDestination.completeProfile;
  });

  @override
  Future<void> sendPasswordReset(String email) => _guard(() async {
    try {
      await _auth.setLanguageCode(emailLanguage);
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error, stackTrace) {
      final failure = AuthErrorMapper.map(error, stackTrace);
      if (failure is NetworkFailure || failure is TooManyRequests) {
        throw failure;
      }
      // Unknown email and the like: behave as if it was sent.
    }
  });

  @override
  Future<void> signOut() => _guard(() async {
    await _auth.signOut();
    await _quietly('sign out of Google', () async {
      await _ensureGoogle();
      await _google.signOut();
    });
  });

  Future<void> _deleteQuietly(User user) =>
      _quietly('delete the account after a failed sign-up', user.delete);

  /// Runs a best-effort [action]: failures are only logged.
  Future<void> _quietly(String what, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      developer.log(
        'Could not $what',
        name: 'fbu.auth',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => FirebaseAuthRepository(
  auth: ref.watch(firebaseAuthProvider),
  google: ref.watch(googleSignInProvider),
  nicknames: ref.watch(nicknameRepositoryProvider),
  profiles: ref.watch(userProfileRepositoryProvider),
);
