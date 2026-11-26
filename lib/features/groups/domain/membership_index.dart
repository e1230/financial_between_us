import 'group.dart';

/// Changes that bring the membership index of a user (`userGroups/{uid}`)
/// in line with the groups they are actually an active member of.
class MembershipIndexDiff {
  const MembershipIndexDiff({required this.toAdd, required this.toRemove});

  /// Active groups missing from the index.
  final List<String> toAdd;

  /// Indexed groups where the user is no longer an active member.
  final List<String> toRemove;

  bool get isEmpty => toAdd.isEmpty && toRemove.isEmpty;
}

/// Compares the [indexed] group ids of [uid] with [groups] (as listed by
/// `watchMyGroups`, which also holds pending requests).
///
/// Only active memberships of non-archived groups belong in the index.
MembershipIndexDiff diffMembershipIndex({
  required String uid,
  required List<Group> groups,
  required List<String> indexed,
}) {
  final active = {
    for (final g in groups)
      if (g.deletedAt == null && g.isActiveMember(uid)) g.id,
  };
  final current = indexed.toSet();
  return MembershipIndexDiff(
    toAdd: [
      for (final id in active)
        if (!current.contains(id)) id,
    ],
    toRemove: [
      for (final id in current)
        if (!active.contains(id)) id,
    ],
  );
}
