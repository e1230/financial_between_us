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

    /// Creator and admin of the group.
    required String ownerUid,

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

  // DECISIÓN: for now the only admin is the creator. Several admins will
  // come with group management (roles in `groups/{gid}/members/{uid}`).
  bool isAdmin(String uid) => ownerUid == uid;

  /// Two letters of the group mosaic ("FJ" for "Fútbol de los jueves").
  String get initials => GroupInitials.of(name);
}
