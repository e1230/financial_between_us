import 'group.dart';
import 'group_failure.dart';

/// What leaving a group means for a user, decided from the group as it is
/// now (see [planLeave]).
sealed class LeavePlan {
  const LeavePlan();
}

/// A member who is not the owner leaves; nothing else changes.
final class LeaveAsMember extends LeavePlan {
  const LeaveAsMember();
}

/// The owner leaves and [newOwnerUid], the oldest active member left,
/// becomes the admin.
final class LeaveAndTransfer extends LeavePlan {
  const LeaveAndTransfer(this.newOwnerUid);

  final String newOwnerUid;
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
/// "Oldest" relies on `members` being in join order: joining always
/// appends (the security rules enforce it), so the first remaining uid is
/// the one who joined first.
LeavePlan planLeave(Group group, String uid) {
  if (group.deletedAt != null) throw const NotAMember();
  if (group.isPending(uid)) return const CancelRequest();
  if (!group.isActiveMember(uid)) throw const NotAMember();
  if (!group.isAdmin(uid)) return const LeaveAsMember();
  final remaining = group.memberUids.where((u) => u != uid);
  return remaining.isEmpty
      ? const LeaveAndArchive()
      : LeaveAndTransfer(remaining.first);
}
