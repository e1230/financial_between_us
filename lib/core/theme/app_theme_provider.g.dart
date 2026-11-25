// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme of the app: the dark theme with the signed-in user's color as the
/// accent. Signed out (or with an unreadable stored color) it is the brand
/// green.

@ProviderFor(appTheme)
final appThemeProvider = AppThemeProvider._();

/// Theme of the app: the dark theme with the signed-in user's color as the
/// accent. Signed out (or with an unreadable stored color) it is the brand
/// green.

final class AppThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  /// Theme of the app: the dark theme with the signed-in user's color as the
  /// accent. Signed out (or with an unreadable stored color) it is the brand
  /// green.
  AppThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return appTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$appThemeHash() => r'f0d25fc600ff36b32a1fc015b15c8ed558577b62';
