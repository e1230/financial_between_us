import 'dart:async';

import 'package:financial_between_us/features/groups/data/groups_repository.dart';
import 'package:financial_between_us/features/groups/domain/active_group.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/group_code_lookup.dart';
import 'package:financial_between_us/features/groups/domain/group_failure.dart';
import 'package:financial_between_us/features/groups/domain/group_member.dart';
import 'package:financial_between_us/features/groups/domain/group_settings.dart';
import 'package:financial_between_us/features/groups/domain/join_outcome.dart';
import 'package:financial_between_us/features/groups/domain/leave_plan.dart';

/// Groups in memory. [passwords] maps a join code to its password.
class FakeGroupsRepository implements GroupsRepository {
  FakeGroupsRepository({List<Group>? groups, Map<String, String>? passwords})
    : groups = [...?groups],
      passwords = {...?passwords};

  final List<Group> groups;
  final Map<String, String> passwords;

  /// Thrown by the next request.
  GroupFailure? failure;

  /// When each uid joined (or asked to join); defaults to the group date.
  final Map<String, DateTime> joinedAt = {};

  /// Code given to the next created group.
  String nextCode = 'NUE-2345';

  final List<String> calls = [];
  final _changes = StreamController<void>.broadcast();

  void _throwIfNeeded() {
    final pending = failure;
    if (pending != null) {
      failure = null;
      throw pending;
    }
  }

  void _put(Group group) {
    groups
      ..removeWhere((g) => g.id == group.id)
      ..add(group);
    _changes.add(null);
  }

  List<Group> _mine(String uid) => sortGroupsFor(
    uid,
    groups.where((g) => g.isActiveMember(uid) || g.isPending(uid)),
  );

  @override
  Stream<List<Group>> watchMyGroups(String uid) async* {
    yield _mine(uid);
    yield* _changes.stream.map((_) => _mine(uid));
  }

  @override
  Future<CreatedGroup> createGroup({
    required String uid,
    required String name,
    required bool requiresApproval,
    String? password,
  }) async {
    calls.add('create:$name');
    _throwIfNeeded();
    final id = 'g${groups.length + 1}';
    final withPassword = password != null && password.isNotEmpty;
    if (withPassword) passwords[nextCode] = password;
    _put(
      Group(
        id: id,
        name: name.trim(),
        code: nextCode,
        ownerUid: uid,
        adminUids: [uid],
        requiresApproval: requiresApproval,
        hasPassword: withPassword,
        memberUids: [uid],
        createdAt: DateTime(2026, 11, 25),
      ),
    );
    return CreatedGroup(
      groupId: id,
      name: name.trim(),
      code: nextCode,
      hasPassword: withPassword,
    );
  }

  @override
  Future<GroupCodeLookup> lookupCode(String code) async {
    calls.add('lookup:$code');
    _throwIfNeeded();
    final group = groups.where((g) => g.code == code).firstOrNull;
    if (group == null) throw const GroupCodeNotFound();
    return GroupCodeLookup(
      code: code,
      groupId: group.id,
      groupName: group.name,
      hasPassword: group.hasPassword,
      requiresApproval: group.requiresApproval,
      passwordSalt: group.hasPassword ? 'salt' : null,
    );
  }

  @override
  Future<bool> isMember({required String groupId, required String uid}) async {
    final group = groups.firstWhere((g) => g.id == groupId);
    return group.isActiveMember(uid) || group.isPending(uid);
  }

  @override
  Future<JoinOutcome> join({
    required GroupCodeLookup group,
    required String uid,
    String? password,
  }) async {
    calls.add('join:${group.code}');
    _throwIfNeeded();
    if (group.hasPassword && passwords[group.code] != password) {
      throw const WrongGroupPassword();
    }
    final current = groups.firstWhere((g) => g.id == group.groupId);
    if (group.requiresApproval) {
      _put(current.copyWith(pendingUids: [...current.pendingUids, uid]));
      return PendingApproval(group.groupName);
    }
    _put(current.copyWith(memberUids: [...current.memberUids, uid]));
    return Joined(group.groupId);
  }

  @override
  Future<void> leave({required String groupId, required String uid}) async {
    calls.add('leave:$groupId');
    _throwIfNeeded();
    final current = groups.where((g) => g.id == groupId).firstOrNull;
    if (current == null) throw const NotAMember();
    final without = current.memberUids.where((u) => u != uid).toList();
    _put(switch (planLeave(current, uid)) {
      CancelRequest() => current.copyWith(
        pendingUids: current.pendingUids.where((u) => u != uid).toList(),
      ),
      LeaveAsMember() => current.copyWith(
        memberUids: without,
        adminUids: current.adminUids.where((u) => u != uid).toList(),
      ),
      LeaveAndTransfer(:final newOwnerUid, :final adminUids) =>
        current.copyWith(
          memberUids: without,
          ownerUid: newOwnerUid,
          adminUids: adminUids,
        ),
      LeaveAndArchive() => current.copyWith(
        memberUids: without,
        deletedAt: DateTime(2026, 11, 25),
      ),
    });
  }

  @override
  Stream<List<GroupMember>> watchMembers(String groupId) async* {
    List<GroupMember> members() {
      final group = groups.where((g) => g.id == groupId).firstOrNull;
      if (group == null) return const [];
      GroupMember member(String uid, MemberStatus status) => GroupMember(
        uid: uid,
        role: group.isAdmin(uid) ? MemberRole.admin : MemberRole.member,
        status: status,
        joinedAt: joinedAt[uid] ?? group.createdAt,
      );
      return [
        for (final uid in group.memberUids) member(uid, MemberStatus.active),
        for (final uid in group.pendingUids) member(uid, MemberStatus.pending),
      ];
    }

    yield members();
    yield* _changes.stream.map((_) => members());
  }

  Group _asAdmin(String groupId, String adminUid) {
    final group = groups.where((g) => g.id == groupId).firstOrNull;
    if (group == null) throw const NotAMember();
    if (!group.isAdmin(adminUid)) throw const NotGroupAdmin();
    return group;
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) async {
    calls.add('remove:$memberUid');
    _throwIfNeeded();
    final group = _asAdmin(groupId, adminUid);
    if (memberUid == adminUid || !group.isActiveMember(memberUid)) {
      throw const NotAMember();
    }
    if (!group.canRemove(adminUid, memberUid)) throw const NotGroupOwner();
    _put(
      group.copyWith(
        memberUids: group.memberUids.where((u) => u != memberUid).toList(),
        adminUids: group.adminUids.where((u) => u != memberUid).toList(),
      ),
    );
  }

  @override
  Future<void> updateSettings({
    required String groupId,
    required String adminUid,
    required GroupSettings settings,
  }) async {
    calls.add('update:$groupId');
    _throwIfNeeded();
    final group = _asAdmin(groupId, adminUid);
    switch (settings.password) {
      case SetPassword(:final password):
        passwords[group.code] = password;
      case RemovePassword():
        passwords.remove(group.code);
      case KeepPassword():
        break;
    }
    _put(
      group.copyWith(
        name: settings.name.trim(),
        requiresApproval: settings.requiresApproval,
        hasPassword: settings.hasPasswordFor(group),
      ),
    );
  }

  @override
  Future<void> promoteMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) async {
    calls.add('promote:$memberUid');
    _throwIfNeeded();
    final group = _asAdmin(groupId, adminUid);
    if (!group.isActiveMember(memberUid)) throw const NotAMember();
    if (!group.canPromote(adminUid, memberUid)) return;
    _put(group.copyWith(adminUids: [...group.adminUids, memberUid]));
  }

  @override
  Future<void> demoteMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) async {
    calls.add('demote:$memberUid');
    _throwIfNeeded();
    final group = _asAdmin(groupId, adminUid);
    if (!group.isOwner(adminUid) || group.isOwner(memberUid)) {
      throw const NotGroupOwner();
    }
    if (!group.canDemote(adminUid, memberUid)) return;
    _put(
      group.copyWith(
        adminUids: group.adminUids.where((u) => u != memberUid).toList(),
      ),
    );
  }

  @override
  Future<void> approveMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) async {
    calls.add('approve:$memberUid');
    _throwIfNeeded();
    final group = _asAdmin(groupId, adminUid);
    if (!group.isPending(memberUid)) throw const NotAMember();
    joinedAt[memberUid] = DateTime(2026, 11, 25);
    _put(
      group.copyWith(
        pendingUids: group.pendingUids.where((u) => u != memberUid).toList(),
        memberUids: [...group.memberUids, memberUid],
      ),
    );
  }

  @override
  Future<void> rejectMember({
    required String groupId,
    required String adminUid,
    required String memberUid,
  }) async {
    calls.add('reject:$memberUid');
    _throwIfNeeded();
    final group = _asAdmin(groupId, adminUid);
    if (!group.isPending(memberUid)) throw const NotAMember();
    _put(
      group.copyWith(
        pendingUids: group.pendingUids.where((u) => u != memberUid).toList(),
      ),
    );
  }
}
