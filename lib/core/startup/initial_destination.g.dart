// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_destination.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves [InitialDestination] after [appStartup], while the splash plays.
///
/// With a session it reads `users/{uid}` (from the cache when offline); if
/// that fails the splash shows its error state with a retry button.

@ProviderFor(initialDestination)
final initialDestinationProvider = InitialDestinationProvider._();

/// Resolves [InitialDestination] after [appStartup], while the splash plays.
///
/// With a session it reads `users/{uid}` (from the cache when offline); if
/// that fails the splash shows its error state with a retry button.

final class InitialDestinationProvider
    extends
        $FunctionalProvider<
          AsyncValue<InitialDestination>,
          InitialDestination,
          FutureOr<InitialDestination>
        >
    with
        $FutureModifier<InitialDestination>,
        $FutureProvider<InitialDestination> {
  /// Resolves [InitialDestination] after [appStartup], while the splash plays.
  ///
  /// With a session it reads `users/{uid}` (from the cache when offline); if
  /// that fails the splash shows its error state with a retry button.
  InitialDestinationProvider._()
    : super(
        from: null,
        argument: null,
        retry: noStartupRetry,
        name: r'initialDestinationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialDestinationHash();

  @$internal
  @override
  $FutureProviderElement<InitialDestination> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InitialDestination> create(Ref ref) {
    return initialDestination(ref);
  }
}

String _$initialDestinationHash() =>
    r'6793facacc924dcd0ab858e4597c8ae6cfcab307';
