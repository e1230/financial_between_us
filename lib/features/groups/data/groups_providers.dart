import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/data/firestore_providers.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/active_group.dart';
import '../domain/group.dart';
import 'groups_repository.dart';
import 'selected_group_repository.dart';

part 'groups_providers.g.dart';

@Riverpod(keepAlive: true)
GroupsRepository groupsRepository(Ref ref) =>
    FirestoreGroupsRepository(ref.watch(firebaseFirestoreProvider));

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
