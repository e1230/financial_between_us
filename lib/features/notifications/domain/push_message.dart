import '../../balances/domain/ledger_movement.dart';

/// A notification received from the Worker: the data of an FCM message,
/// already validated. Built with [PushMessage.parse].
sealed class PushMessage {
  const PushMessage({
    required this.groupId,
    required this.groupName,
    required this.actorUid,
    required this.actorName,
    required this.recipientUid,
  });

  final String groupId;
  final String groupName;

  /// Who did it.
  final String actorUid;

  /// Their full name (or nickname).
  final String actorName;

  /// Who it is for: the device may have another account signed in.
  final String recipientUid;

  /// Stable key of what it is about, so a newer notification replaces an
  /// older one of the same thing.
  String get key;

  /// The original data, kept as the payload of the local notification.
  Map<String, String> toData();

  /// `null` when [data] is not a notification of this app (or is from a
  /// newer version that this one does not understand).
  static PushMessage? parse(Map<String, Object?> data) {
    String? text(String key) {
      final value = data[key];
      return value is String ? value : null;
    }

    final type = text('type');
    final groupId = text('groupId');
    final actorUid = text('actorUid');
    final recipientUid = text('recipientUid');
    if (type == null ||
        groupId == null ||
        groupId.isEmpty ||
        actorUid == null ||
        actorUid.isEmpty ||
        recipientUid == null ||
        recipientUid.isEmpty) {
      return null;
    }
    final groupName = text('groupName') ?? '';
    final actorName = text('actorName') ?? '';

    final movementKind = MovementPushKind.fromWire(type);
    if (movementKind != null) {
      final movementId = text('movementId');
      final movementType = LedgerMovementType.fromWire(text('movementType'));
      final debtorUid = text('debtorUid');
      final creditorUid = text('creditorUid');
      final amount = int.tryParse(text('amount') ?? '');
      if (movementId == null ||
          movementId.isEmpty ||
          movementType == null ||
          debtorUid == null ||
          creditorUid == null ||
          amount == null) {
        return null;
      }
      return MovementPush(
        kind: movementKind,
        groupId: groupId,
        groupName: groupName,
        actorUid: actorUid,
        actorName: actorName,
        recipientUid: recipientUid,
        movementId: movementId,
        movementType: movementType,
        debtorUid: debtorUid,
        creditorUid: creditorUid,
        amount: amount,
        concept: text('concept') ?? '',
        rejectReason: RejectReason.fromWire(text('rejectReason')),
      );
    }

    final memberKind = MemberPushKind.fromWire(type);
    final memberUid = text('memberUid');
    if (memberKind == null || memberUid == null || memberUid.isEmpty) {
      return null;
    }
    return MemberPush(
      kind: memberKind,
      groupId: groupId,
      groupName: groupName,
      actorUid: actorUid,
      actorName: actorName,
      recipientUid: recipientUid,
      memberUid: memberUid,
      memberName: text('memberName') ?? '',
    );
  }
}

enum MovementPushKind {
  created('movement.created'),
  rejected('movement.rejected'),
  deleted('movement.deleted');

  const MovementPushKind(this.wire);

  final String wire;

  static MovementPushKind? fromWire(String? value) {
    for (final kind in values) {
      if (kind.wire == value) return kind;
    }
    return null;
  }
}

/// A payment or a debt between [actorUid] and [recipientUid].
final class MovementPush extends PushMessage {
  const MovementPush({
    required this.kind,
    required super.groupId,
    required super.groupName,
    required super.actorUid,
    required super.actorName,
    required super.recipientUid,
    required this.movementId,
    required this.movementType,
    required this.debtorUid,
    required this.creditorUid,
    required this.amount,
    required this.concept,
    this.rejectReason,
  });

  final MovementPushKind kind;
  final String movementId;
  final LedgerMovementType movementType;
  final String debtorUid;
  final String creditorUid;

  /// Whole pesos.
  final int amount;

  /// Empty for payments.
  final String concept;

  /// Only when [kind] is [MovementPushKind.rejected].
  final RejectReason? rejectReason;

  bool get isPayment => movementType == LedgerMovementType.payment;

  /// For a payment, the one who paid; for a debt, the one who owes.
  bool get actorIsDebtor => actorUid == debtorUid;

  /// The recipient can still answer it ("Confirmar" / "Rechazar").
  bool get canAnswer => kind == MovementPushKind.created;

  @override
  String get key => keyOf(movementId);

  /// [key] of the notifications of the movement [movementId].
  static String keyOf(String movementId) => 'movement_$movementId';

  @override
  Map<String, String> toData() => {
    'type': kind.wire,
    'groupId': groupId,
    'groupName': groupName,
    'actorUid': actorUid,
    'actorName': actorName,
    'recipientUid': recipientUid,
    'movementId': movementId,
    'movementType': movementType.wire,
    'debtorUid': debtorUid,
    'creditorUid': creditorUid,
    'amount': '$amount',
    'concept': concept,
    if (rejectReason case final reason?) 'rejectReason': reason.wire,
  };
}

enum MemberPushKind {
  joined('member.joined'),
  requested('member.requested'),
  left('member.left'),
  approved('member.approved'),
  removed('member.removed');

  const MemberPushKind(this.wire);

  final String wire;

  static MemberPushKind? fromWire(String? value) {
    for (final kind in values) {
      if (kind.wire == value) return kind;
    }
    return null;
  }
}

/// Someone joined, asked to join, left, was approved or was removed.
final class MemberPush extends PushMessage {
  const MemberPush({
    required this.kind,
    required super.groupId,
    required super.groupName,
    required super.actorUid,
    required super.actorName,
    required super.recipientUid,
    required this.memberUid,
    required this.memberName,
  });

  final MemberPushKind kind;

  /// Whose membership changed (the actor, except for approvals and
  /// removals, done by an admin).
  final String memberUid;
  final String memberName;

  /// The recipient is the one approved or removed.
  bool get isAboutRecipient => memberUid == recipientUid;

  @override
  String get key => 'member_${groupId}_$memberUid';

  @override
  Map<String, String> toData() => {
    'type': kind.wire,
    'groupId': groupId,
    'groupName': groupName,
    'actorUid': actorUid,
    'actorName': actorName,
    'recipientUid': recipientUid,
    'memberUid': memberUid,
    'memberName': memberName,
  };
}
