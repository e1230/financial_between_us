import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_providers.dart';
import '../../features/auth/domain/session_destination.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/profile/data/profile_providers.dart';
import 'app_startup.dart';

part 'initial_destination.g.dart';

/// Where the app goes when the splash finishes.
enum InitialDestination {
  home,
  walkthrough,
  welcome,
  chooseNickname,
  completeProfile,
}

/// Decides the first screen after the splash:
///
/// - Active session → where that session belongs ([session]): home, or the
///   step of the sign-up the user left unfinished (choose a nickname after a
///   first Google sign-in, or complete the profile).
/// - No session and nobody ever signed in on this device → walkthrough.
/// - No session, but someone signed in before (e.g. signed out) → welcome.
InitialDestination resolveInitialDestination({
  required SessionDestination? session,
  required bool hasEverSignedIn,
}) => switch (session) {
  SessionDestination.home => InitialDestination.home,
  SessionDestination.chooseNickname => InitialDestination.chooseNickname,
  SessionDestination.completeProfile => InitialDestination.completeProfile,
  null =>
    hasEverSignedIn
        ? InitialDestination.welcome
        : InitialDestination.walkthrough,
};

/// Resolves [InitialDestination] after [appStartup], while the splash plays.
///
/// With a session it reads `users/{uid}` (from the cache when offline); if
/// that fails the splash shows its error state with a retry button.
@Riverpod(keepAlive: true, retry: noStartupRetry)
Future<InitialDestination> initialDestination(Ref ref) async {
  await ref.watch(appStartupProvider.future);
  final user = ref.watch(firebaseAuthProvider).currentUser;
  final repository = ref.watch(onboardingRepositoryProvider);
  final session = user == null
      ? null
      : sessionDestinationFor(
          await ref.read(userProfileRepositoryProvider).fetch(user.uid),
        );
  return resolveInitialDestination(
    session: session,
    hasEverSignedIn: await repository.hasEverSignedIn(),
  );
}
