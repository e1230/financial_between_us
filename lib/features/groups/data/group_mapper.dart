import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/group.dart';
import '../domain/group_code_lookup.dart';
import '../domain/group_member.dart';

/// Field names of `groups/{groupId}`.
abstract final class GroupFields {
  static const String name = 'name';
  static const String code = 'code';
  static const String ownerUid = 'ownerUid';
  static const String requiresApproval = 'requiresApproval';
  static const String hasPassword = 'hasPassword';
  static const String members = 'members';
  static const String pendingMembers = 'pendingMembers';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String deletedAt = 'deletedAt';
}

/// Field names of `groups/{groupId}/members/{uid}`.
abstract final class MemberFields {
  static const String role = 'role';
  static const String status = 'status';
  static const String joinedAt = 'joinedAt';

  /// Set when the user leaves (or cancels the request); the document stays.
  static const String leftAt = 'leftAt';

  /// Set when the admin removes the member (or rejects the request).
  static const String removedAt = 'removedAt';
  static const String removedBy = 'removedBy';

  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';
  static const String statusActive = 'active';
  static const String statusPending = 'pending';

  /// Former member: left the group or withdrew the request.
  static const String statusLeft = 'left';

  /// Removed by the admin, or request rejected.
  static const String statusRemoved = 'removed';
}

/// Field names of `groupCodes/{code}`.
abstract final class GroupCodeFields {
  static const String groupId = 'gid';
  static const String name = 'name';
  static const String hasPassword = 'hasPassword';
  static const String requiresApproval = 'requiresApproval';
  static const String salt = 'salt';
  static const String createdAt = 'createdAt';

  /// Set when the group is archived: the code no longer works.
  static const String deletedAt = 'deletedAt';
}

/// Field of `secrets/password` and `joinProofs/{uid}`.
abstract final class GroupSecretFields {
  static const String hash = 'hash';
}

/// Field names of `groups/{groupId}/auditLog/{logId}`.
abstract final class AuditLogFields {
  static const String action = 'action';
  static const String entity = 'entity';
  static const String entityId = 'entityId';
  static const String before = 'before';
  static const String after = 'after';
  static const String uid = 'uid';
  static const String timestamp = 'timestamp';

  static const String actionCreate = 'create';
  static const String actionJoin = 'join';
  static const String actionRequest = 'request';
  static const String actionLeave = 'leave';
  static const String actionCancelRequest = 'cancelRequest';
  static const String actionTransferOwnership = 'transferOwnership';
  static const String actionArchive = 'archive';
  static const String actionRemove = 'remove';
  static const String actionApprove = 'approve';
  static const String actionReject = 'reject';
  static const String entityGroup = 'group';
  static const String entityMember = 'member';
}

/// Converts group documents to domain objects and back.
abstract final class GroupMapper {
  /// Reads `groups/{groupId}`. Missing optional values fall back to their
  /// defaults so an old document never crashes the app.
  static Group fromFirestore(String id, Map<String, dynamic> data) => Group(
    id: id,
    name: data[GroupFields.name] as String? ?? '',
    code: data[GroupFields.code] as String? ?? '',
    ownerUid: data[GroupFields.ownerUid] as String? ?? '',
    requiresApproval: data[GroupFields.requiresApproval] as bool? ?? false,
    hasPassword: data[GroupFields.hasPassword] as bool? ?? false,
    memberUids: _uids(data[GroupFields.members]),
    pendingUids: _uids(data[GroupFields.pendingMembers]),
    createdAt: _date(data[GroupFields.createdAt]),
    deletedAt: _date(data[GroupFields.deletedAt]),
  );

  /// Document of a new group: its creator is the only (active) member.
  static Map<String, Object?> newGroup({
    required String name,
    required String code,
    required String ownerUid,
    required bool requiresApproval,
    required bool hasPassword,
  }) => {
    GroupFields.name: name,
    GroupFields.code: code,
    GroupFields.ownerUid: ownerUid,
    GroupFields.requiresApproval: requiresApproval,
    GroupFields.hasPassword: hasPassword,
    GroupFields.members: [ownerUid],
    GroupFields.pendingMembers: <String>[],
    GroupFields.createdAt: FieldValue.serverTimestamp(),
    GroupFields.updatedAt: FieldValue.serverTimestamp(),
    GroupFields.deletedAt: null,
  };

  /// `groups/{groupId}/members/{uid}`.
  static Map<String, Object?> member({
    required bool isAdmin,
    required bool isActive,
  }) => {
    MemberFields.role: isAdmin
        ? MemberFields.roleAdmin
        : MemberFields.roleMember,
    MemberFields.status: isActive
        ? MemberFields.statusActive
        : MemberFields.statusPending,
    MemberFields.joinedAt: FieldValue.serverTimestamp(),
  };

  /// Changes of a member document when the user leaves the group.
  static Map<String, Object?> leftMember() => {
    MemberFields.role: MemberFields.roleMember,
    MemberFields.status: MemberFields.statusLeft,
    MemberFields.leftAt: FieldValue.serverTimestamp(),
  };

  /// Whether a member document belongs to a current member (active or
  /// pending), not to someone who left.
  static bool isCurrentMember(Map<String, dynamic>? data) {
    if (data == null) return false;
    final status = data[MemberFields.status];
    return status != MemberFields.statusLeft &&
        status != MemberFields.statusRemoved;
  }

  /// Reads `groups/{groupId}/members/{uid}`. An unknown role is a plain
  /// member and an unknown status counts as active.
  static GroupMember memberFromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) => GroupMember(
    uid: uid,
    role: data[MemberFields.role] == MemberFields.roleAdmin
        ? MemberRole.admin
        : MemberRole.member,
    status: switch (data[MemberFields.status]) {
      MemberFields.statusPending => MemberStatus.pending,
      MemberFields.statusLeft => MemberStatus.left,
      MemberFields.statusRemoved => MemberStatus.removed,
      _ => MemberStatus.active,
    },
    joinedAt: _date(data[MemberFields.joinedAt]),
  );

  /// Changes of a member document removed by [adminUid] (also a rejected
  /// request).
  static Map<String, Object?> removedMember(String adminUid) => {
    MemberFields.status: MemberFields.statusRemoved,
    MemberFields.removedAt: FieldValue.serverTimestamp(),
    MemberFields.removedBy: adminUid,
  };

  /// `groupCodes/{code}`.
  static Map<String, Object?> codeEntry({
    required String groupId,
    required String name,
    required bool requiresApproval,
    required String? salt,
  }) => {
    GroupCodeFields.groupId: groupId,
    GroupCodeFields.name: name,
    GroupCodeFields.hasPassword: salt != null,
    GroupCodeFields.requiresApproval: requiresApproval,
    GroupCodeFields.salt: salt,
    GroupCodeFields.createdAt: FieldValue.serverTimestamp(),
  };

  /// Reads `groupCodes/{code}`, or `null` if malformed or archived.
  static GroupCodeLookup? lookupFromFirestore(
    String code,
    Map<String, dynamic> data,
  ) {
    if (data[GroupCodeFields.deletedAt] != null) return null;
    final groupId = data[GroupCodeFields.groupId];
    if (groupId is! String || groupId.isEmpty) return null;
    return GroupCodeLookup(
      code: code,
      groupId: groupId,
      groupName: data[GroupCodeFields.name] as String? ?? '',
      hasPassword: data[GroupCodeFields.hasPassword] as bool? ?? false,
      requiresApproval:
          data[GroupCodeFields.requiresApproval] as bool? ?? false,
      passwordSalt: data[GroupCodeFields.salt] as String?,
    );
  }

  /// An `auditLog` entry written by [uid], with the server time.
  static Map<String, Object?> auditEntry({
    required String action,
    required String entity,
    required String entityId,
    required String uid,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) => {
    AuditLogFields.action: action,
    AuditLogFields.entity: entity,
    AuditLogFields.entityId: entityId,
    AuditLogFields.before: before,
    AuditLogFields.after: after,
    AuditLogFields.uid: uid,
    AuditLogFields.timestamp: FieldValue.serverTimestamp(),
  };

  static List<String> _uids(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  static DateTime? _date(Object? value) =>
      value is Timestamp ? value.toDate() : null;
}
