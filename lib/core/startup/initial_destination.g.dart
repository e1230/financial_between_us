// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_destination.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolves [InitialDestination] after [appStartup], while the splash plays.

@ProviderFor(initialDestination)
final initialDestinationProvider = InitialDestinationProvider._();

/// Resolves [InitialDestination] after [appStartup], while the splash plays.

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
    r'139fa8888f8eb284ad546bd31dbf17c9b1387b37';
