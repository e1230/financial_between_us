import '../domain/group_event.dart';

/// Events of a group that a debt can belong to.
abstract interface class GroupEventsRepository {
  /// Events of [groupId], newest first.
  Stream<List<GroupEvent>> watch(String groupId);
}

/// No events yet: "Registrar deuda" only offers "Sin evento · deuda
/// directa".
// TODO: read `groups/{gid}/outings` when the Eventos module exists.
class NoGroupEventsRepository implements GroupEventsRepository {
  const NoGroupEventsRepository();

  @override
  Stream<List<GroupEvent>> watch(String groupId) => Stream.value(const []);
}
