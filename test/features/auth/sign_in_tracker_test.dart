import 'package:financial_between_us/core/startup/app_startup.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/sign_in_tracker.dart';
import 'package:financial_between_us/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  late FakeFirebaseAuth auth;
  late OnboardingRepository repository;
  late ProviderContainer container;

  setUp(() async {
    auth = FakeFirebaseAuth();
    repository = OnboardingRepository(FakeSharedPreferencesAsync());
    container = ProviderContainer.test(
      overrides: [
        appStartupProvider.overrideWith((ref) async {}),
        firebaseAuthProvider.overrideWithValue(auth),
        onboardingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await container.read(signInTrackerProvider.future);
  });

  test('a signed-out state does not mark the flag', () async {
    auth.authStates.add(null);
    await pumpEventQueue();

    expect(await repository.hasEverSignedIn(), isFalse);
  });

  test('any successful sign-in marks the flag', () async {
    auth.authStates.add(FakeUser());
    await pumpEventQueue();

    expect(await repository.hasEverSignedIn(), isTrue);
  });

  test('the flag survives a later sign-out', () async {
    auth.authStates
      ..add(FakeUser())
      ..add(null);
    await pumpEventQueue();

    expect(await repository.hasEverSignedIn(), isTrue);
  });
}
