import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/firestore_providers.dart';
import '../../auth/data/auth_providers.dart';
import '../../notifications/data/notifications_data_providers.dart';
import '../../notifications/data/notifying_groups_repository.dart';
import '../domain/active_group.dart';
import '../domain/group.dart';
import '../domain/group_member.dart';
import '../domain/membership_index.dart';
import 'groups_repository.dart';
import 'membership_index_repository.dart';
import 'selected_group_repository.dart';

part 'groups_providers.g.dart';

/// Groups; joining, leaving, approving and removing also notify the
/// people concerned.
@Riverpod(keepAlive: true)
GroupsRepository groupsRepository(Ref ref) => NotifyingGroupsRepository(
  FirestoreGroupsRepository(ref.watch(firebaseFirestoreProvider)),
  ref.watch(notificationDispatcherProvider),
);

@Riverpod(keepAlive: true)
SelectedGroupRepository selectedGroupRepository(Ref ref) =>
    SelectedGroupRepository(SharedPreferencesAsync());

/// Live groups of the signed-in user (active and pending), in selector
/// order. Empty when signed out.
@Riverpod(keepAlive: true)
Stream<List<Group>> myGroups(Ref ref) async* {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* ref.watch(groupsRepositoryProvider).watchMyGroups(user.uid);
}

/// Id of the group chosen in the selector, remembered across launches.
@Riverpod(keepAlive: true)
class SelectedGroupId extends _$SelectedGroupId {
  @override
  Future<String?> build() => ref.watch(selectedGroupRepositoryProvider).read();

  /// Shows [groupId] in the Home and remembers it.
  Future<void> select(String groupId) async {
    state = AsyncData(groupId);
    await ref.read(selectedGroupRepositoryProvider).write(groupId);
  }
}

/// The group the Home shows, or `null` without active groups (see
/// [resolveActiveGroup]).
@Riverpod(keepAlive: true)
Future<Group?> activeGroup(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return null;
  final groups = await ref.watch(myGroupsProvider.future);
  final selectedId = await ref.watch(selectedGroupIdProvider.future);
  return resolveActiveGroup(
    groups: groups,
    selectedId: selectedId,
    uid: user.uid,
  );
}

/// The group [groupId] while the user is an active or pending member of
/// it; `null` once they left, were removed or it was archived.
@riverpod
Future<Group?> groupById(Ref ref, String groupId) async {
  final groups = await ref.watch(myGroupsProvider.future);
  return groups.where((g) => g.id == groupId).firstOrNull;
}

/// Live current members of [groupId], the admin first and then by join
/// date (see [sortMembers]).
@riverpod
Stream<List<GroupMember>> groupMembers(Ref ref, String groupId) async* {
  final group = await ref.watch(groupByIdProvider(groupId).future);
  if (group == null) {
    yield const [];
    return;
  }
  final ownerUid = group.ownerUid;
  yield* ref
      .watch(groupsRepositoryProvider)
      .watchMembers(groupId)
      .map((members) => sortMembers(members, ownerUid));
}

@Riverpod(keepAlive: true)
MembershipIndexRepository membershipIndexRepository(Ref ref) =>
    FirestoreMembershipIndexRepository(ref.watch(firebaseFirestoreProvider));

/// Repairs the signed-in user's `userGroups/{uid}` whenever their groups
/// change: adds active groups that are missing (e.g. joined before the
/// index existed) and removes the ones they no longer belong to. Errors
/// are only logged; the next change of the groups tries again.
///
/// Kept alive for the whole session from `FbuApp`.
@Riverpod(keepAlive: true)
Future<void> membershipIndexSync(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return;
  final groups = await ref.watch(myGroupsProvider.future);
  final index = ref.watch(membershipIndexRepositoryProvider);
  try {
    final diff = diffMembershipIndex(
      uid: user.uid,
      groups: groups,
      indexed: await index.read(user.uid),
    );
    // One group per write: the security rules check each one.
    for (final gid in diff.toAdd) {
      await index.add(uid: user.uid, groupId: gid);
    }
    for (final gid in diff.toRemove) {
      await index.remove(uid: user.uid, groupId: gid);
    }
  } catch (error, stackTrace) {
    developer.log(
      'Could not sync the membership index',
      name: 'fbu.groups',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
