import 'dart:async';

import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/auth/data/nickname_repository.dart';
import 'package:financial_between_us/features/auth/domain/auth_failure.dart';
import 'package:financial_between_us/features/auth/domain/session_destination.dart';
import 'package:financial_between_us/features/profile/data/avatar_picker.dart';
import 'package:financial_between_us/features/profile/data/avatar_uploader.dart';
import 'package:financial_between_us/features/profile/data/user_profile_repository.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory [SharedPreferencesAsync] (booleans and strings).
class FakeSharedPreferencesAsync extends Fake
    implements SharedPreferencesAsync {
  FakeSharedPreferencesAsync([Map<String, Object>? values])
    : values = {...?values};

  final Map<String, Object> values;

  /// Keys written, in order.
  final List<String> writes = [];

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    writes.add(key);
    values[key] = value;
  }

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    writes.add(key);
    values[key] = value;
  }
}

class FakeUserInfo extends Fake implements UserInfo {
  FakeUserInfo(this.providerId);

  @override
  final String providerId;
}

class FakeUser extends Fake implements User {
  FakeUser({
    this.uid = 'uid-1',
    this.email = 'juan@correo.com',
    this.displayName,
    this.password = 'cuentasclaras',
    List<String> providerIds = const ['password'],
  }) : providerData = [for (final id in providerIds) FakeUserInfo(id)];

  @override
  final String uid;

  @override
  final String? email;

  @override
  String? displayName;

  @override
  final List<UserInfo> providerData;

  /// Current password, checked by [reauthenticateWithCredential].
  String password;

  /// Thrown by the next [updatePassword] (e.g. `weak-password`).
  FirebaseAuthException? updatePasswordError;

  bool reauthenticated = false;
  bool deleted = false;

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    if (credential is! EmailAuthCredential ||
        credential.email != email ||
        credential.password != password) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    reauthenticated = true;
    return FakeUserCredential(this);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final pending = updatePasswordError;
    if (pending != null) {
      updatePasswordError = null;
      throw pending;
    }
    if (!reauthenticated) {
      throw FirebaseAuthException(code: 'requires-recent-login');
    }
    password = newPassword;
  }

  @override
  Future<void> delete() async => deleted = true;

  @override
  Future<void> updateDisplayName(String? displayName) async =>
      this.displayName = displayName;
}

class FakeUserCredential extends Fake implements UserCredential {
  FakeUserCredential(this.user);

  @override
  final User? user;
}

/// [FirebaseAuth] with a controllable [currentUser] and auth stream.
///
/// Email accounts live in [passwords]; set [error] to make the next call
/// throw it.
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  FakeFirebaseAuth({this.currentUser, Map<String, String>? passwords})
    : passwords = {...?passwords};

  @override
  User? currentUser;

  final Map<String, String> passwords;
  FirebaseAuthException? error;

  /// The user returned by sign-up and credential sign-in.
  FakeUser nextUser = FakeUser();

  final List<String> resetEmails = [];
  String? emailLanguage;
  bool signedOut = false;

  final StreamController<User?> authStates = StreamController<User?>();

  @override
  Stream<User?> authStateChanges() => authStates.stream;

  void _throwIfNeeded() {
    final pending = error;
    if (pending != null) {
      error = null;
      throw pending;
    }
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _throwIfNeeded();
    if (passwords[email] != password) {
      throw FirebaseAuthException(code: 'invalid-credential');
    }
    final user = FakeUser(uid: 'uid-$email', email: email);
    currentUser = user;
    return FakeUserCredential(user);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _throwIfNeeded();
    if (passwords.containsKey(email)) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    passwords[email] = password;
    currentUser = nextUser;
    return FakeUserCredential(nextUser);
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    _throwIfNeeded();
    currentUser = nextUser;
    return FakeUserCredential(nextUser);
  }

  @override
  Future<void> setLanguageCode(String? languageCode) async =>
      emailLanguage = languageCode;

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    _throwIfNeeded();
    resetEmails.add(email);
  }

  @override
  Future<void> signOut() async {
    signedOut = true;
    currentUser = null;
  }
}

/// Google sign-in that returns [account] or throws [error].
class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  GoogleSignInException? error;
  int initializeCalls = 0;
  bool signedOut = false;

  @override
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async => initializeCalls++;

  @override
  Future<GoogleSignInAccount> authenticate({
    List<String> scopeHint = const <String>[],
  }) async {
    final pending = error;
    if (pending != null) throw pending;
    return FakeGoogleSignInAccount();
  }

  @override
  Future<void> signOut() async => signedOut = true;
}

class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  GoogleSignInAuthentication get authentication =>
      const GoogleSignInAuthentication(idToken: 'id-token');
}

/// `nicknames/{nickname}` in memory: nickname → email.
class FakeNicknameRepository implements NicknameRepository {
  FakeNicknameRepository([Map<String, String>? emails]) : emails = {...?emails};

  final Map<String, String> emails;

  @override
  Future<bool> isAvailable(String nickname) async =>
      !emails.containsKey(nickname);

  @override
  Future<String?> emailFor(String nickname) async => emails[nickname];
}

/// `users/{uid}` in memory.
class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository({
    Map<String, UserProfile>? profiles,
    this.nicknames,
  }) : profiles = {...?profiles};

  final Map<String, UserProfile> profiles;

  /// Shared with a [FakeNicknameRepository] to simulate reservations.
  final FakeNicknameRepository? nicknames;

  /// Thrown by the next [createWithNickname] (e.g. a race for the nickname).
  Object? createError;

  /// Thrown by the next [completeProfile].
  Object? completeError;

  /// Thrown by the next [updateProfile].
  Object? updateError;

  /// Arguments of every [updateProfile] call.
  final List<UserProfile> updates = [];

  final StreamController<UserProfile?> _changes =
      StreamController<UserProfile?>.broadcast();

  @override
  Future<void> createWithNickname({
    required String uid,
    required String nickname,
    required String email,
    required String displayName,
  }) async {
    final pending = createError;
    if (pending != null) {
      createError = null;
      throw pending;
    }
    if (nicknames?.emails.containsKey(nickname) ?? false) {
      throw const NicknameTakenException();
    }
    nicknames?.emails[nickname] = email;
    _put(
      UserProfile(
        uid: uid,
        displayName: displayName,
        nickname: nickname,
        email: email,
      ),
    );
  }

  @override
  Future<UserProfile?> fetch(String uid) async => profiles[uid];

  @override
  Stream<UserProfile?> watch(String uid) async* {
    yield profiles[uid];
    yield* _changes.stream.where((p) => p == null || p.uid == uid);
  }

  @override
  Future<void> completeProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int colorValue,
  }) async {
    final pending = completeError;
    if (pending != null) {
      completeError = null;
      throw pending;
    }
    _put(
      profiles[uid]!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
        colorValue: colorValue,
        profileCompleted: true,
      ),
    );
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int colorValue,
  }) async {
    final pending = updateError;
    if (pending != null) {
      updateError = null;
      throw pending;
    }
    final updated = profiles[uid]!.copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
      colorValue: colorValue,
    );
    updates.add(updated);
    _put(updated);
  }

  void _put(UserProfile profile) {
    profiles[profile.uid] = profile;
    _changes.add(profile);
  }
}

/// [AuthRepository] for widget tests: each call records its arguments and
/// returns [result] or throws [failure].
class FakeAuthRepository implements AuthRepository {
  SessionDestination result = SessionDestination.home;

  /// `null` simulates the user closing the Google dialog.
  SessionDestination? googleResult = SessionDestination.home;
  AuthFailure? failure;

  /// Completes the pending request; `null` completes immediately.
  Completer<void>? gate;

  final List<String> calls = [];

  Future<void> _run(String call) async {
    calls.add(call);
    await gate?.future;
    final pending = failure;
    if (pending != null) throw pending;
  }

  @override
  Future<SessionDestination> signIn({
    required String identifier,
    required String password,
  }) async {
    await _run('signIn:$identifier');
    return result;
  }

  @override
  Future<SessionDestination> register({
    required String nickname,
    required String email,
    required String password,
  }) async {
    await _run('register:$nickname:$email');
    return SessionDestination.completeProfile;
  }

  @override
  Future<SessionDestination?> signInWithGoogle() async {
    await _run('google');
    return googleResult;
  }

  @override
  Future<SessionDestination> claimNickname(String nickname) async {
    await _run('claim:$nickname');
    return SessionDestination.completeProfile;
  }

  @override
  Future<void> sendPasswordReset(String email) => _run('reset:$email');

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _run('changePassword:$currentPassword:$newPassword');

  @override
  Future<void> signOut() => _run('signOut');
}

class FakeAvatarUploader implements AvatarUploader {
  final List<String> uploads = [];
  bool fail = false;

  static const String url = 'https://res.cloudinary.com/demo/avatar.jpg';

  @override
  Future<String> upload(String filePath) async {
    uploads.add(filePath);
    if (fail) throw const AvatarUploadException('offline');
    return url;
  }
}

class FakeAvatarPicker implements AvatarPicker {
  String? path;

  @override
  Future<String?> pick(AvatarSource source, AvatarCropStyle style) async =>
      path;
}
