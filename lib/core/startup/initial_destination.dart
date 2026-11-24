import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_providers.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import 'app_startup.dart';

part 'initial_destination.g.dart';

/// Where the app goes when the splash finishes.
enum InitialDestination { home, walkthrough, welcome }

/// Decides the first screen after the splash:
///
/// - Active session → home.
/// - No session and nobody ever signed in on this device → walkthrough.
/// - No session, but someone signed in before (e.g. signed out) → welcome.
InitialDestination resolveInitialDestination({
  required bool hasSession,
  required bool hasEverSignedIn,
}) {
  if (hasSession) return InitialDestination.home;
  return hasEverSignedIn
      ? InitialDestination.welcome
      : InitialDestination.walkthrough;
}

/// Resolves [InitialDestination] after [appStartup], while the splash plays.
@Riverpod(keepAlive: true, retry: noStartupRetry)
Future<InitialDestination> initialDestination(Ref ref) async {
  await ref.watch(appStartupProvider.future);
  final auth = ref.watch(firebaseAuthProvider);
  final repository = ref.watch(onboardingRepositoryProvider);
  return resolveInitialDestination(
    hasSession: auth.currentUser != null,
    hasEverSignedIn: await repository.hasEverSignedIn(),
  );
}
