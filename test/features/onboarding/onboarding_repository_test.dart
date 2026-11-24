import 'package:financial_between_us/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

void main() {
  late FakeSharedPreferencesAsync prefs;
  late OnboardingRepository repository;

  setUp(() {
    prefs = FakeSharedPreferencesAsync();
    repository = OnboardingRepository(prefs);
  });

  test('nobody has signed in on a fresh install', () async {
    expect(await repository.hasEverSignedIn(), isFalse);
  });

  test('markSignedIn persists the flag under its key', () async {
    await repository.markSignedIn();

    expect(await repository.hasEverSignedIn(), isTrue);
    expect(prefs.values, {'fbu.has_ever_signed_in': true});
  });

  test('markSignedIn writes only once', () async {
    await repository.markSignedIn();
    await repository.markSignedIn();

    expect(prefs.writes, ['fbu.has_ever_signed_in']);
  });
}
