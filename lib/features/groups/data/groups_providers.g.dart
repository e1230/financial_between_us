// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Groups; joining, leaving, approving and removing also notify the
/// people concerned.

@ProviderFor(groupsRepository)
final groupsRepositoryProvider = GroupsRepositoryProvider._();

/// Groups; joining, leaving, approving and removing also notify the
/// people concerned.

final class GroupsRepositoryProvider
    extends
        $FunctionalProvider<
          GroupsRepository,
          GroupsRepository,
          GroupsRepository
        >
    with $Provider<GroupsRepository> {
  /// Groups; joining, leaving, approving and removing also notify the
  /// people concerned.
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

String _$groupsRepositoryHash() => r'321a211b766ed252c4b7b19ea0f7a38e7f299736';

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

/// The group [groupId] while the user is an active or pending member of
/// it; `null` once they left, were removed or it was archived.

@ProviderFor(groupById)
final groupByIdProvider = GroupByIdFamily._();

/// The group [groupId] while the user is an active or pending member of
/// it; `null` once they left, were removed or it was archived.

final class GroupByIdProvider
    extends $FunctionalProvider<AsyncValue<Group?>, Group?, FutureOr<Group?>>
    with $FutureModifier<Group?>, $FutureProvider<Group?> {
  /// The group [groupId] while the user is an active or pending member of
  /// it; `null` once they left, were removed or it was archived.
  GroupByIdProvider._({
    required GroupByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupByIdHash();

  @override
  String toString() {
    return r'groupByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Group?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Group?> create(Ref ref) {
    final argument = this.argument as String;
    return groupById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupByIdHash() => r'2076d3b9bc93328927d51fad8a8ee9384b967486';

/// The group [groupId] while the user is an active or pending member of
/// it; `null` once they left, were removed or it was archived.

final class GroupByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Group?>, String> {
  GroupByIdFamily._()
    : super(
        retry: null,
        name: r'groupByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The group [groupId] while the user is an active or pending member of
  /// it; `null` once they left, were removed or it was archived.

  GroupByIdProvider call(String groupId) =>
      GroupByIdProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupByIdProvider';
}

/// Live current members of [groupId], the admin first and then by join
/// date (see [sortMembers]).

@ProviderFor(groupMembers)
final groupMembersProvider = GroupMembersFamily._();

/// Live current members of [groupId], the admin first and then by join
/// date (see [sortMembers]).

final class GroupMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupMember>>,
          List<GroupMember>,
          Stream<List<GroupMember>>
        >
    with
        $FutureModifier<List<GroupMember>>,
        $StreamProvider<List<GroupMember>> {
  /// Live current members of [groupId], the admin first and then by join
  /// date (see [sortMembers]).
  GroupMembersProvider._({
    required GroupMembersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupMembersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMembersHash();

  @override
  String toString() {
    return r'groupMembersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupMember>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupMember>> create(Ref ref) {
    final argument = this.argument as String;
    return groupMembers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMembersHash() => r'7899e74183a193b25ae95b57788d1092b966f9a8';

/// Live current members of [groupId], the admin first and then by join
/// date (see [sortMembers]).

final class GroupMembersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GroupMember>>, String> {
  GroupMembersFamily._()
    : super(
        retry: null,
        name: r'groupMembersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live current members of [groupId], the admin first and then by join
  /// date (see [sortMembers]).

  GroupMembersProvider call(String groupId) =>
      GroupMembersProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupMembersProvider';
}

@ProviderFor(membershipIndexRepository)
final membershipIndexRepositoryProvider = MembershipIndexRepositoryProvider._();

final class MembershipIndexRepositoryProvider
    extends
        $FunctionalProvider<
          MembershipIndexRepository,
          MembershipIndexRepository,
          MembershipIndexRepository
        >
    with $Provider<MembershipIndexRepository> {
  MembershipIndexRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipIndexRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipIndexRepositoryHash();

  @$internal
  @override
  $ProviderElement<MembershipIndexRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MembershipIndexRepository create(Ref ref) {
    return membershipIndexRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembershipIndexRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembershipIndexRepository>(value),
    );
  }
}

String _$membershipIndexRepositoryHash() =>
    r'51d443d82d90d029e72671af709cedfc103c5e6a';

/// Repairs the signed-in user's `userGroups/{uid}` whenever their groups
/// change: adds active groups that are missing (e.g. joined before the
/// index existed) and removes the ones they no longer belong to. Errors
/// are only logged; the next change of the groups tries again.
///
/// Kept alive for the whole session from `FbuApp`.

@ProviderFor(membershipIndexSync)
final membershipIndexSyncProvider = MembershipIndexSyncProvider._();

/// Repairs the signed-in user's `userGroups/{uid}` whenever their groups
/// change: adds active groups that are missing (e.g. joined before the
/// index existed) and removes the ones they no longer belong to. Errors
/// are only logged; the next change of the groups tries again.
///
/// Kept alive for the whole session from `FbuApp`.

final class MembershipIndexSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Repairs the signed-in user's `userGroups/{uid}` whenever their groups
  /// change: adds active groups that are missing (e.g. joined before the
  /// index existed) and removes the ones they no longer belong to. Errors
  /// are only logged; the next change of the groups tries again.
  ///
  /// Kept alive for the whole session from `FbuApp`.
  MembershipIndexSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membershipIndexSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membershipIndexSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return membershipIndexSync(ref);
  }
}

String _$membershipIndexSyncHash() =>
    r'0a497d334d0fa6ece4762873ed0fb95f8bc79ce6';
