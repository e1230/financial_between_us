import 'dart:async';
import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/startup/app_startup.dart';
import '../../onboarding/data/onboarding_repository.dart';
import 'auth_providers.dart';

part 'sign_in_tracker.g.dart';

/// Marks `fbu.has_ever_signed_in` the first time a user signs in on this
/// device, whatever the method (email, username, sign-up or Google).
///
/// Listening to `authStateChanges()` here means sign-in screens don't need to
/// remember to do it. Kept alive for the whole app session from `FbuApp`.
@Riverpod(keepAlive: true)
Future<void> signInTracker(Ref ref) async {
  await ref.watch(appStartupProvider.future);
  final auth = ref.watch(firebaseAuthProvider);
  final repository = ref.watch(onboardingRepositoryProvider);

  final subscription = auth.authStateChanges().listen(
    (user) {
      if (user == null) return;
      unawaited(
        repository.markSignedIn().catchError((Object error, StackTrace st) {
          developer.log(
            'Could not persist the sign-in flag',
            name: 'fbu.auth',
            error: error,
            stackTrace: st,
          );
        }),
      );
    },
    onError: (Object error, StackTrace st) => developer.log(
      'Auth state stream failed',
      name: 'fbu.auth',
      error: error,
      stackTrace: st,
    ),
  );
  ref.onDispose(subscription.cancel);
}
