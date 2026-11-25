// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupsRepository)
final groupsRepositoryProvider = GroupsRepositoryProvider._();

final class GroupsRepositoryProvider
    extends
        $FunctionalProvider<
          GroupsRepository,
          GroupsRepository,
          GroupsRepository
        >
    with $Provider<GroupsRepository> {
  GroupsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupsRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupsRepository create(Ref ref) {
    return groupsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupsRepository>(value),
    );
  }
}

String _$groupsRepositoryHash() => r'b17a557553df054a2801b5ebc3522622a88f33bd';

@ProviderFor(selectedGroupRepository)
final selectedGroupRepositoryProvider = SelectedGroupRepositoryProvider._();

final class SelectedGroupRepositoryProvider
    extends
        $FunctionalProvider<
          SelectedGroupRepository,
          SelectedGroupRepository,
          SelectedGroupRepository
        >
    with $Provider<SelectedGroupRepository> {
  SelectedGroupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedGroupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedGroupRepositoryHash();

  @$internal
  @override
  $ProviderElement<SelectedGroupRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelectedGroupRepository create(Ref ref) {
    return selectedGroupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectedGroupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectedGroupRepository>(value),
    );
  }
}

String _$selectedGroupRepositoryHash() =>
    r'e6fda775f0d0394e4086eeb45f88aeb085ae526d';

/// Live groups of the signed-in user (active and pending), in selector
/// order. Empty when signed out.

@ProviderFor(myGroups)
final myGroupsProvider = MyGroupsProvider._();

/// Live groups of the signed-in user (active and pending), in selector
/// order. Empty when signed out.

final class MyGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Group>>,
          List<Group>,
          Stream<List<Group>>
        >
    with $FutureModifier<List<Group>>, $StreamProvider<List<Group>> {
  /// Live groups of the signed-in user (active and pending), in selector
  /// order. Empty when signed out.
  MyGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myGroupsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myGroupsHash();

  @$internal
  @override
  $StreamProviderElement<List<Group>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Group>> create(Ref ref) {
    return myGroups(ref);
  }
}

String _$myGroupsHash() => r'f4700bc944b0d9aa6dbc936c6084f9486585b82e';

/// Id of the group chosen in the selector, remembered across launches.

@ProviderFor(SelectedGroupId)
final selectedGroupIdProvider = SelectedGroupIdProvider._();

/// Id of the group chosen in the selector, remembered across launches.
final class SelectedGroupIdProvider
    extends $AsyncNotifierProvider<SelectedGroupId, String?> {
  /// Id of the group chosen in the selector, remembered across launches.
  SelectedGroupIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedGroupIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedGroupIdHash();

  @$internal
  @override
  SelectedGroupId create() => SelectedGroupId();
}

String _$selectedGroupIdHash() => r'c2d741e2091379303e4e7c160fd93832b0e1e8ad';

/// Id of the group chosen in the selector, remembered across launches.

abstract class _$SelectedGroupId extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The group the Home shows, or `null` without active groups (see
/// [resolveActiveGroup]).

@ProviderFor(activeGroup)
final activeGroupProvider = ActiveGroupProvider._();

/// The group the Home shows, or `null` without active groups (see
/// [resolveActiveGroup]).

final class ActiveGroupProvider
    extends $FunctionalProvider<AsyncValue<Group?>, Group?, FutureOr<Group?>>
    with $FutureModifier<Group?>, $FutureProvider<Group?> {
  /// The group the Home shows, or `null` without active groups (see
  /// [resolveActiveGroup]).
  ActiveGroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeGroupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeGroupHash();

  @$internal
  @override
  $FutureProviderElement<Group?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Group?> create(Ref ref) {
    return activeGroup(ref);
  }
}

String _$activeGroupHash() => r'a3ef81778cc93124e028f2e7c1843479f0770e30';
