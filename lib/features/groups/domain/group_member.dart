import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member.freezed.dart';

/// Role of a member in a group.
enum MemberRole { admin, member }

/// Where a member stands in a group.
enum MemberStatus {
  active,

  /// Waiting for the admin's approval.
  pending,

  /// Left the group or withdrew the request.
  left,

  /// Removed by the admin (or request rejected). May join again.
  removed;

  /// Active or pending: still part of the group.
  bool get isCurrent => this == active || this == pending;
}

/// A member of a group (`groups/{groupId}/members/{uid}`).
@freezed
abstract class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String uid,
    @Default(MemberRole.member) MemberRole role,
    @Default(MemberStatus.active) MemberStatus status,

    /// When the member joined (approved, for groups with approval) or, while
    /// pending, when they asked to join. `null` while a write is pending.
    DateTime? joinedAt,
  }) = _GroupMember;
}

/// Order of the member list: the [ownerUid] first, then the other admins,
/// then everybody else; each part by [joinedAt] (oldest first, unknown
/// dates last).
List<GroupMember> sortMembers(Iterable<GroupMember> members, String ownerUid) {
  final list = members.toList();
  list.sort((a, b) {
    if (a.uid == ownerUid) return -1;
    if (b.uid == ownerUid) return 1;
    if (a.role != b.role) return a.role == MemberRole.admin ? -1 : 1;
    final da = a.joinedAt;
    final db = b.joinedAt;
    if (da == null && db == null) return a.uid.compareTo(b.uid);
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });
  return list;
}
