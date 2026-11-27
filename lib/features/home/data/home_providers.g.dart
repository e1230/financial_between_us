// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeActivityRepository)
final homeActivityRepositoryProvider = HomeActivityRepositoryProvider._();

final class HomeActivityRepositoryProvider
    extends
        $FunctionalProvider<
          HomeActivityRepository,
          HomeActivityRepository,
          HomeActivityRepository
        >
    with $Provider<HomeActivityRepository> {
  HomeActivityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeActivityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeActivityRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeActivityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HomeActivityRepository create(Ref ref) {
    return homeActivityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeActivityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeActivityRepository>(value),
    );
  }
}

String _$homeActivityRepositoryHash() =>
    r'770f63ab4af7333941044abaa668c547d49996c9';

/// Period of the Home chart; kept while the app is open.

@ProviderFor(SelectedPeriod)
final selectedPeriodProvider = SelectedPeriodProvider._();

/// Period of the Home chart; kept while the app is open.
final class SelectedPeriodProvider
    extends $NotifierProvider<SelectedPeriod, ActivityPeriod> {
  /// Period of the Home chart; kept while the app is open.
  SelectedPeriodProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedPeriodProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedPeriodHash();

  @$internal
  @override
  SelectedPeriod create() => SelectedPeriod();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActivityPeriod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActivityPeriod>(value),
    );
  }
}

String _$selectedPeriodHash() => r'a0c9f6c66e79d28251f1cbe09f1a73986fb96400';

/// Period of the Home chart; kept while the app is open.

abstract class _$SelectedPeriod extends $Notifier<ActivityPeriod> {
  ActivityPeriod build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ActivityPeriod, ActivityPeriod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActivityPeriod, ActivityPeriod>,
              ActivityPeriod,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Latest movements of the active group that involve the user.

@ProviderFor(recentMovements)
final recentMovementsProvider = RecentMovementsProvider._();

/// Latest movements of the active group that involve the user.

final class RecentMovementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Movement>>,
          List<Movement>,
          FutureOr<List<Movement>>
        >
    with $FutureModifier<List<Movement>>, $FutureProvider<List<Movement>> {
  /// Latest movements of the active group that involve the user.
  RecentMovementsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentMovementsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentMovementsHash();

  @$internal
  @override
  $FutureProviderElement<List<Movement>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Movement>> create(Ref ref) {
    return recentMovements(ref);
  }
}

String _$recentMovementsHash() => r'659345515803fde16bb544af4b9d2bfed731f43d';

/// Chart series of the active group in the selected period.

@ProviderFor(activitySeries)
final activitySeriesProvider = ActivitySeriesProvider._();

/// Chart series of the active group in the selected period.

final class ActivitySeriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<ActivitySeries?>,
          ActivitySeries?,
          Stream<ActivitySeries?>
        >
    with $FutureModifier<ActivitySeries?>, $StreamProvider<ActivitySeries?> {
  /// Chart series of the active group in the selected period.
  ActivitySeriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activitySeriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activitySeriesHash();

  @$internal
  @override
  $StreamProviderElement<ActivitySeries?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ActivitySeries?> create(Ref ref) {
    return activitySeries(ref);
  }
}

String _$activitySeriesHash() => r'0b1dcc0686ac9d4cf67485ab35d15ce6464c5d9a';

/// Version of the installed app, like "1.0.0".

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// Version of the installed app, like "1.0.0".

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Version of the installed app, like "1.0.0".
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'59b58cc8214f60571dfe517b1f68cfc1aed29718';
