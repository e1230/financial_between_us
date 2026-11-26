import 'group.dart';
import 'group_failure.dart';

/// What leaving a group means for a user, decided from the group as it is
/// now (see [planLeave]).
sealed class LeavePlan {
  const LeavePlan();
}

/// A member who is not the owner leaves (an admin also stops being one);
/// nothing else changes.
final class LeaveAsMember extends LeavePlan {
  const LeaveAsMember();
}

/// The owner leaves and the group gets a new main admin, [newOwnerUid]:
/// the oldest of the other admins ([wasAdmin]) or, without them, the
/// oldest active member, who becomes an admin.
final class LeaveAndTransfer extends LeavePlan {
  const LeaveAndTransfer({required this.adminUids, required this.wasAdmin})
    : assert(adminUids.length > 0);

  /// Admins once the owner leaves, in promotion order: the new owner first.
  final List<String> adminUids;

  /// The new owner was already an admin.
  final bool wasAdmin;

  String get newOwnerUid => adminUids.first;
}

/// The owner was the only active member: the group is archived (soft
/// delete) and its join code stops working.
final class LeaveAndArchive extends LeavePlan {
  const LeaveAndArchive();
}

/// A pending member withdraws the join request.
final class CancelRequest extends LeavePlan {
  const CancelRequest();
}

/// How [uid] leaves [group]. Throws [NotAMember] if [uid] is neither an
/// active nor a pending member (or the group is archived).
///
/// "Oldest" admin relies on `admins` being in promotion order, and oldest
/// member on `members` being in join order: both only ever append (the
/// security rules enforce it).
LeavePlan planLeave(Group group, String uid) {
  if (group.deletedAt != null) throw const NotAMember();
  if (group.isPending(uid)) return const CancelRequest();
  if (!group.isActiveMember(uid)) throw const NotAMember();
  if (!group.isOwner(uid)) return const LeaveAsMember();
  final otherAdmins = group.adminUids.where((u) => u != uid).toList();
  if (otherAdmins.isNotEmpty) {
    return LeaveAndTransfer(adminUids: otherAdmins, wasAdmin: true);
  }
  final remaining = group.memberUids.where((u) => u != uid);
  return remaining.isEmpty
      ? const LeaveAndArchive()
      : LeaveAndTransfer(adminUids: [remaining.first], wasAdmin: false);
}
