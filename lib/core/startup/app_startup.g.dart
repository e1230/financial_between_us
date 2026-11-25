// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One-time app initialization, run while the splash is on screen.
///
/// Failures are not retried automatically: the splash shows an error state
/// with a retry button that invalidates this provider.

@ProviderFor(appStartup)
final appStartupProvider = AppStartupProvider._();

/// One-time app initialization, run while the splash is on screen.
///
/// Failures are not retried automatically: the splash shows an error state
/// with a retry button that invalidates this provider.

final class AppStartupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// One-time app initialization, run while the splash is on screen.
  ///
  /// Failures are not retried automatically: the splash shows an error state
  /// with a retry button that invalidates this provider.
  AppStartupProvider._()
    : super(
        from: null,
        argument: null,
        retry: noStartupRetry,
        name: r'appStartupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStartupHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return appStartup(ref);
  }
}

String _$appStartupHash() => r'f8d94c9d38e7d0fecc7ce9fba45ca6ce5e76a0de';
