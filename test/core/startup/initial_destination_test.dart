import 'dart:async';

import 'package:financial_between_us/core/startup/app_startup.dart';
import 'package:financial_between_us/core/startup/initial_destination.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/onboarding/data/onboarding_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  group('resolveInitialDestination', () {
    test('goes home when there is an active session', () {
      expect(
        resolveInitialDestination(hasSession: true, hasEverSignedIn: false),
        InitialDestination.home,
      );
      expect(
        resolveInitialDestination(hasSession: true, hasEverSignedIn: true),
        InitialDestination.home,
      );
    });

    test('shows the walkthrough if nobody ever signed in on the device', () {
      expect(
        resolveInitialDestination(hasSession: false, hasEverSignedIn: false),
        InitialDestination.walkthrough,
      );
    });

    test('goes to welcome after a sign-out', () {
      expect(
        resolveInitialDestination(hasSession: false, hasEverSignedIn: true),
        InitialDestination.welcome,
      );
    });
  });

  group('initialDestinationProvider', () {
    ProviderContainer container({User? user, bool everSignedIn = false}) {
      final prefs = FakeSharedPreferencesAsync({
        if (everSignedIn) OnboardingRepository.hasEverSignedInKey: true,
      });
      return ProviderContainer.test(
        overrides: [
          appStartupProvider.overrideWith((ref) async {}),
          firebaseAuthProvider.overrideWithValue(
            FakeFirebaseAuth(currentUser: user),
          ),
          onboardingRepositoryProvider.overrideWithValue(
            OnboardingRepository(prefs),
          ),
        ],
      );
    }

    test('first launch → walkthrough', () async {
      final destination = await container().read(
        initialDestinationProvider.future,
      );
      expect(destination, InitialDestination.walkthrough);
    });

    test('signed out after a previous sign-in → welcome', () async {
      final destination = await container(everSignedIn: true)
          .read(initialDestinationProvider.future);
      expect(destination, InitialDestination.welcome);
    });

    test('active session → home', () async {
      final destination = await container(
        user: FakeUser(),
        everSignedIn: true,
      ).read(initialDestinationProvider.future);
      expect(destination, InitialDestination.home);
    });

    test('waits for app startup', () async {
      final startup = Completer<void>();
      final c = ProviderContainer.test(
        overrides: [
          appStartupProvider.overrideWith((ref) => startup.future),
          firebaseAuthProvider.overrideWithValue(FakeFirebaseAuth()),
          onboardingRepositoryProvider.overrideWithValue(
            OnboardingRepository(FakeSharedPreferencesAsync()),
          ),
        ],
      );
      var resolved = false;
      unawaited(
        c.read(initialDestinationProvider.future).then((_) => resolved = true),
      );
      await Future<void>.delayed(Duration.zero);
      expect(resolved, isFalse);

      startup.complete();
      await c.read(initialDestinationProvider.future);
      expect(resolved, isTrue);
    });
  });
}
