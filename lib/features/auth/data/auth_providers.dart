import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/startup/app_startup.dart';

part 'auth_providers.g.dart';

/// The [FirebaseAuth] instance. Only read it after `appStartupProvider` has
/// completed (Firebase must be initialized). Overridden in tests.
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// The [GoogleSignIn] singleton (google_sign_in 7.x). Overridden in tests.
@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) => GoogleSignIn.instance;

/// The signed-in Firebase user, or `null`. Waits for app startup.
@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) async* {
  await ref.watch(appStartupProvider.future);
  yield* ref.watch(firebaseAuthProvider).authStateChanges();
}
