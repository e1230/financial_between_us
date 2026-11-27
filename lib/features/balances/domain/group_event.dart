/// An event (outing) of a group that a debt can belong to.
final class GroupEvent {
  const GroupEvent({required this.id, required this.name, required this.date});

  final String id;

  /// Place or name, like "Andrés Carne de Res".
  final String name;
  final DateTime date;
}
