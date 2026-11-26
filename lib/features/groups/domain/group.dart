import 'package:freezed_annotation/freezed_annotation.dart';

import 'group_initials.dart';

part 'group.freezed.dart';

/// A group of friends (`groups/{groupId}` in Firestore).
///
/// Pure domain entity: the data layer converts Firestore types.
@freezed
abstract class Group with _$Group {
  const factory Group({
    required String id,
    required String name,

    /// Join code, like `LIQ-7K4P` (see `GroupCode`).
    required String code,

    /// Main admin: the creator, or whoever inherited the group when the
    /// previous one left. Always the first of [adminUids]; nobody can
    /// remove them or take away their role.
    required String ownerUid,

    /// Active members who administer the group, in the order they became
    /// admins (the owner first).
    @Default(<String>[]) List<String> adminUids,

    /// New members wait for the admin's approval.
    @Default(false) bool requiresApproval,

    /// A password is asked for when joining.
    @Default(false) bool hasPassword,

    /// Active members.
    @Default(<String>[]) List<String> memberUids,

    /// Members waiting for approval.
    @Default(<String>[]) List<String> pendingUids,

    /// Set by the server; `null` while a local write is pending.
    DateTime? createdAt,

    /// Soft delete: nothing is physically deleted.
    DateTime? deletedAt,
  }) = _Group;

  const Group._();

  /// Number of active members.
  int get memberCount => memberUids.length;

  bool isActiveMember(String uid) => memberUids.contains(uid);

  bool isPending(String uid) =>
      !isActiveMember(uid) && pendingUids.contains(uid);

  /// Whether [uid] is the main admin.
  bool isOwner(String uid) => ownerUid == uid;

  /// Whether [uid] administers the group (the owner always does).
  bool isAdmin(String uid) => isOwner(uid) || adminUids.contains(uid);

  /// Admins approve and reject requests, remove plain members and promote
  /// members to admin. Only the owner removes or demotes another admin.
  bool canRemove(String adminUid, String memberUid) =>
      isAdmin(adminUid) &&
      memberUid != adminUid &&
      !isOwner(memberUid) &&
      isActiveMember(memberUid) &&
      (!isAdmin(memberUid) || isOwner(adminUid));

  /// Whether [adminUid] can make the active member [memberUid] an admin.
  bool canPromote(String adminUid, String memberUid) =>
      isAdmin(adminUid) && isActiveMember(memberUid) && !isAdmin(memberUid);

  /// Whether [adminUid] can turn the admin [memberUid] back into a plain
  /// member.
  bool canDemote(String adminUid, String memberUid) =>
      isOwner(adminUid) && !isOwner(memberUid) && adminUids.contains(memberUid);

  /// Two letters of the group mosaic ("FJ" for "Fútbol de los jueves").
  String get initials => GroupInitials.of(name);
}
