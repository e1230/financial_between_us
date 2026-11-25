import 'dart:async';

import 'package:financial_between_us/core/startup/app_startup.dart';
import 'package:financial_between_us/core/startup/initial_destination.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/domain/session_destination.dart';
import 'package:financial_between_us/features/onboarding/data/onboarding_repository.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  group('resolveInitialDestination', () {
    test('a session goes where it belongs, whatever the device flag', () {
      for (final everSignedIn in [false, true]) {
        expect(
          resolveInitialDestination(
            session: SessionDestination.home,
            hasEverSignedIn: everSignedIn,
          ),
          InitialDestination.home,
        );
        expect(
          resolveInitialDestination(
            session: SessionDestination.chooseNickname,
            hasEverSignedIn: everSignedIn,
          ),
          InitialDestination.chooseNickname,
        );
        expect(
          resolveInitialDestination(
            session: SessionDestination.completeProfile,
            hasEverSignedIn: everSignedIn,
          ),
          InitialDestination.completeProfile,
        );
      }
    });

    test('shows the walkthrough if nobody ever signed in on the device', () {
      expect(
        resolveInitialDestination(session: null, hasEverSignedIn: false),
        InitialDestination.walkthrough,
      );
    });

    test('goes to welcome after a sign-out', () {
      expect(
        resolveInitialDestination(session: null, hasEverSignedIn: true),
        InitialDestination.welcome,
      );
    });
  });

  group('initialDestinationProvider', () {
    ProviderContainer container({
      User? user,
      bool everSignedIn = false,
      Map<String, UserProfile>? profiles,
    }) {
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
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(profiles: profiles),
          ),
        ],
      );
    }

    const profile = UserProfile(
      uid: 'uid-1',
      displayName: 'mao',
      nickname: 'mao',
      email: 'juan@correo.com',
    );

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

    test('active session with a completed profile → home', () async {
      final destination = await container(
        user: FakeUser(),
        everSignedIn: true,
        profiles: {'uid-1': profile.copyWith(profileCompleted: true)},
      ).read(initialDestinationProvider.future);
      expect(destination, InitialDestination.home);
    });

    test('closed the app before finishing the profile → complete it', () async {
      final destination = await container(
        user: FakeUser(),
        everSignedIn: true,
        profiles: {'uid-1': profile},
      ).read(initialDestinationProvider.future);
      expect(destination, InitialDestination.completeProfile);
    });

    test('closed the app before choosing a nickname → choose it', () async {
      final destination = await container(
        user: FakeUser(),
        everSignedIn: true,
      ).read(initialDestinationProvider.future);
      expect(destination, InitialDestination.chooseNickname);
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
