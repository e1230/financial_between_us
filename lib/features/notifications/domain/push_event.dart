/// Something that happened that other people are told about. The app sends
/// it to the notifications Worker right after the write succeeded; the
/// Worker checks it against Firestore and picks the recipients.
sealed class PushEvent {
  const PushEvent(this.groupId);

  final String groupId;

  /// Wire name of the event (`movement.created`, …).
  String get type;

  /// Body of `POST /v1/notify`.
  Map<String, Object> toJson() => {'type': type, 'groupId': groupId};
}

/// What happened to one or more movements of a group.
enum MovementEventKind {
  created('movement.created'),
  rejected('movement.rejected'),
  deleted('movement.deleted');

  const MovementEventKind(this.wire);

  final String wire;
}

final class MovementEvent extends PushEvent {
  const MovementEvent(this.kind, super.groupId, this.movementIds);

  final MovementEventKind kind;

  /// A payment from "Todos los grupos" writes several in one go.
  final List<String> movementIds;

  @override
  String get type => kind.wire;

  @override
  Map<String, Object> toJson() => {
    ...super.toJson(),
    'movementIds': movementIds,
  };
}

/// What the signed-in user did with their own membership.
enum OwnMembershipKind {
  joined('member.joined'),
  requested('member.requested'),
  left('member.left');

  const OwnMembershipKind(this.wire);

  final String wire;
}

final class OwnMembershipEvent extends PushEvent {
  const OwnMembershipEvent(this.kind, super.groupId);

  final OwnMembershipKind kind;

  @override
  String get type => kind.wire;
}

/// What an admin did with someone else's membership.
enum AdminMembershipKind {
  approved('member.approved'),
  removed('member.removed');

  const AdminMembershipKind(this.wire);

  final String wire;
}

final class AdminMembershipEvent extends PushEvent {
  const AdminMembershipEvent(this.kind, super.groupId, this.memberUid);

  final AdminMembershipKind kind;
  final String memberUid;

  @override
  String get type => kind.wire;

  @override
  Map<String, Object> toJson() => {...super.toJson(), 'memberUid': memberUid};
}
