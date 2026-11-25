import 'group.dart';

/// The group the Home shows for [uid]: the [selectedId] one if the user is
/// still an active member, otherwise the first active group, otherwise
/// `null` (no groups, or only pending requests).
Group? resolveActiveGroup({
  required List<Group> groups,
  required String? selectedId,
  required String uid,
}) {
  final active = groups.where((g) => g.isActiveMember(uid)).toList();
  if (active.isEmpty) return null;
  for (final group in active) {
    if (group.id == selectedId) return group;
  }
  return active.first;
}

/// Order of the group selector: active groups first, then pending ones;
/// each part by creation date (oldest first, pending writes last).
List<Group> sortGroupsFor(String uid, Iterable<Group> groups) {
  int byDate(Group a, Group b) {
    final da = a.createdAt;
    final db = b.createdAt;
    if (da == null && db == null) return a.name.compareTo(b.name);
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  final active = groups.where((g) => g.isActiveMember(uid)).toList()
    ..sort(byDate);
  final pending = groups.where((g) => g.isPending(uid)).toList()..sort(byDate);
  return [...active, ...pending];
}
