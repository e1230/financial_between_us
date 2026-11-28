import 'dart:async';

import '../../groups/data/groups_repository.dart';
import '../../groups/domain/group.dart';
import '../../groups/domain/group_code_lookup.dart';
import '../../groups/domain/group_member.dart';
import '../../groups/domain/group_settings.dart';
import '../../groups/domain/join_outcome.dart';
import '../domain/push_event.dart';
import 'notification_dispatcher.dart';

/// [GroupsRepository] that, after each successful change of who is in a
/// group, tells the people concerned (through [NotificationDispatcher]).
/// Everything else goes straight through.
class NotifyingGroupsRepository implements GroupsRepository {
  NotifyingGroupsRepository(this._inner, this._dispatcher);

  final GroupsRepository _inner;
  final NotificationDispatcher _dispatcher;

  void _notify(PushEvent event) => unawaited(_dispatcher.notify(event));

  @override
  Stream<List<Group>> watchMyGroups(String uid) => _inner.watchMyGroups(uid);

  @override
  Future<CreatedGroup> createGroup({
    required String uid,
    required String name,
    required bool requiresApproval,
    String? password,
  }) => _inner.createGroup(
    uid: uid,
    name: name,
    requiresApproval: requiresApproval,
    password: password,
  );

  @override
  Future<GroupCodeLookup> lookupCode(String code) => _inner.lookupCode(code);

  @override
  Future<bool> isMember({required String groupId, required String uid}) =>
      _inner.isMember(groupId: groupId, uid: uid);

  @override
  Future<JoinOutcome> join({
    required GroupCodeLookup group,
    required String uid,
    String? password,
  }) async {
    final outcome = await _inner.join(
      group: group,
      uid: uid,
      password: password,
    );
    _notify(
      OwnMembershipEvent(switch (outcome) {
        Joined() => OwnMembershipKind.joined,
        PendingApproval() => OwnMembershipKind.requested,
      }, group.groupId),
    );
    return outcome;
  }

  /// Withdrawing a pending request is a leave too; the Worker only tells
  /// the group about members who really left (it checks the audit log).
  @override
  Future<void> leave({required String groupId, required String uid}) async {
    await _inner.leave(groupId: groupId, uid: uid);
    _notify(OwnMembershipEvent(OwnMembershipKind.left, groupId));
  }

  @override
  Stream<List<GroupMember>> watchMembers(String groupId) =>
      _inner.watchMembers(groupId);

  @override
  Future<void> removeMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) async {
    await _inner.removeMember(
      groupId: groupId,
      adminUid: adminUid,
      memberUid: memberUid,
    );
    _notify(
      AdminMembershipEvent(AdminMembershipKind.removed, groupId, memberUid),
    );
  }

  @override
  Future<void> approveMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) async {
    await _inner.approveMember(
      groupId: groupId,
      adminUid: adminUid,
      memberUid: memberUid,
    );
    _notify(
      AdminMembershipEvent(AdminMembershipKind.approved, groupId, memberUid),
    );
  }

  @override
  Future<void> rejectMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) => _inner.rejectMember(
    groupId: groupId,
    adminUid: adminUid,
    memberUid: memberUid,
  );

  @override
  Future<void> promoteMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) => _inner.promoteMember(
    groupId: groupId,
    adminUid: adminUid,
    memberUid: memberUid,
  );

  @override
  Future<void> updateSettings({
    required String groupId,
    required String adminUid,
    required GroupSettings settings,
  }) => _inner.updateSettings(
    groupId: groupId,
    adminUid: adminUid,
    settings: settings,
  );

  @override
  Future<void> demoteMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) => _inner.demoteMember(
    groupId: groupId,
    adminUid: adminUid,
    memberUid: memberUid,
  );
}
