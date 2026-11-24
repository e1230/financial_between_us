import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_repository.g.dart';

/// Local (per device) onboarding state.
///
/// Stored in shared preferences, which are excluded from Android Auto Backup
/// (`android/app/src/main/res/xml/`), so a reinstall starts from scratch.
class OnboardingRepository {
  OnboardingRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  /// Set to `true` after the first successful sign-in on this device.
  static const String hasEverSignedInKey = 'fbu.has_ever_signed_in';

  /// Whether someone has ever signed in on this device.
  Future<bool> hasEverSignedIn() async =>
      await _prefs.getBool(hasEverSignedInKey) ?? false;

  /// Remembers that someone signed in on this device. Idempotent.
  Future<void> markSignedIn() async {
    if (await hasEverSignedIn()) return;
    await _prefs.setBool(hasEverSignedInKey, true);
  }
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) =>
    OnboardingRepository(SharedPreferencesAsync());
