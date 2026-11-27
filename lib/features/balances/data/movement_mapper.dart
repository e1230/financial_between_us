import 'package:cloud_firestore/cloud_firestore.dart';

import '../../groups/data/group_mapper.dart' show AuditLogFields;
import '../../payment_accounts/domain/payment_account.dart';
import '../domain/ledger_movement.dart';

/// Field names of `groups/{groupId}/movements/{movementId}`.
abstract final class MovementFields {
  static const String type = 'type';
  static const String debtorUid = 'debtorUid';
  static const String creditorUid = 'creditorUid';

  /// `[debtorUid, creditorUid]`, for `array-contains` queries and rules.
  static const String participants = 'participants';

  /// Both uids sorted and joined with `_` (see `pairKeyOf`), for the
  /// history of a pair.
  static const String pairKey = 'pairKey';
  static const String amount = 'amount';
  static const String kind = 'kind';
  static const String eventId = 'eventId';
  static const String eventName = 'eventName';
  static const String concept = 'concept';

  /// `[{targetId, amount}]`.
  static const String appliedTo = 'appliedTo';
  static const String targetId = 'targetId';

  /// `{type, name, reference}`.
  static const String account = 'account';
  static const String accountType = 'type';
  static const String accountName = 'name';
  static const String accountReference = 'reference';
  static const String note = 'note';

  /// `{url, width, height, bytes}`.
  static const String attachment = 'attachment';
  static const String attachmentUrl = 'url';
  static const String attachmentWidth = 'width';
  static const String attachmentHeight = 'height';
  static const String attachmentBytes = 'bytes';
  static const String date = 'date';
  static const String createdBy = 'createdBy';
  static const String createdAt = 'createdAt';
  static const String status = 'status';
  static const String rejectedAt = 'rejectedAt';
  static const String rejectedBy = 'rejectedBy';
  static const String rejectReason = 'rejectReason';
  static const String rejectNote = 'rejectNote';
  static const String deletedAt = 'deletedAt';
  static const String seenBy = 'seenBy';

  /// `entity` of their `auditLog` entries.
  static const String auditEntity = 'movement';
}

/// Converts movement documents to domain objects and back.
abstract final class MovementMapper {
  /// Reads a movement, or `null` when the document is not a valid one (an
  /// unknown type, a missing party or a non-positive amount), so a broken
  /// document never adds money to a balance.
  static LedgerMovement? fromFirestore(
    String groupId,
    String id,
    Map<String, dynamic> data,
  ) {
    final type = LedgerMovementType.fromWire(data[MovementFields.type]);
    final debtor = data[MovementFields.debtorUid];
    final creditor = data[MovementFields.creditorUid];
    final amount = data[MovementFields.amount];
    final date = _date(data[MovementFields.date]);
    if (type == null ||
        debtor is! String ||
        creditor is! String ||
        debtor.isEmpty ||
        creditor.isEmpty ||
        amount is! int ||
        amount <= 0 ||
        date == null) {
      return null;
    }
    return LedgerMovement(
      id: id,
      groupId: groupId,
      type: type,
      debtorUid: debtor,
      creditorUid: creditor,
      amount: amount,
      kind: DebtKind.fromWire(data[MovementFields.kind]),
      eventId: data[MovementFields.eventId] as String?,
      eventName: data[MovementFields.eventName] as String?,
      concept: data[MovementFields.concept] as String? ?? '',
      appliedTo: _applications(data[MovementFields.appliedTo]),
      account: _account(data[MovementFields.account]),
      note: data[MovementFields.note] as String?,
      attachment: _attachment(data[MovementFields.attachment]),
      date: date,
      createdBy: data[MovementFields.createdBy] as String? ?? '',
      createdAt: _date(data[MovementFields.createdAt]),
      status: MovementStatus.fromWire(data[MovementFields.status]),
      rejectedAt: _date(data[MovementFields.rejectedAt]),
      rejectedBy: data[MovementFields.rejectedBy] as String?,
      rejectReason: RejectReason.fromWire(data[MovementFields.rejectReason]),
      rejectNote: data[MovementFields.rejectNote] as String?,
      deletedAt: _date(data[MovementFields.deletedAt]),
      seenBy: data[MovementFields.seenBy] is List
          ? (data[MovementFields.seenBy] as List).whereType<String>().toList()
          : const [],
    );
  }

  /// What [movement] says, as stored (also the `after` of its audit entry).
  static Map<String, Object?> content(LedgerMovement movement) => {
    MovementFields.type: movement.type.wire,
    MovementFields.debtorUid: movement.debtorUid,
    MovementFields.creditorUid: movement.creditorUid,
    MovementFields.amount: movement.amount,
    if (movement.isDebt) ...{
      MovementFields.kind: movement.kind.wire,
      MovementFields.eventId: movement.eventId,
      MovementFields.eventName: movement.eventName,
    },
    MovementFields.concept: movement.concept.trim(),
    if (movement.isPayment)
      MovementFields.appliedTo: [
        for (final a in movement.appliedTo)
          {
            MovementFields.targetId: a.targetId,
            MovementFields.amount: a.amount,
          },
      ],
    if (movement.account case final account?)
      MovementFields.account: {
        MovementFields.accountType: account.type.wire,
        MovementFields.accountName: account.name,
        MovementFields.accountReference: account.reference,
      },
    MovementFields.note: movement.note,
    if (movement.attachment case final attachment?)
      MovementFields.attachment: {
        MovementFields.attachmentUrl: attachment.url,
        MovementFields.attachmentWidth: attachment.width,
        MovementFields.attachmentHeight: attachment.height,
        MovementFields.attachmentBytes: attachment.bytes,
      },
    MovementFields.date: Timestamp.fromDate(movement.date),
  };

  /// Document of a new movement, registered by `movement.createdBy` (who
  /// has seen it already).
  static Map<String, Object?> create(LedgerMovement movement) => {
    ...content(movement),
    MovementFields.participants: movement.participants,
    MovementFields.pairKey: movement.pairKey,
    MovementFields.createdBy: movement.createdBy,
    MovementFields.createdAt: FieldValue.serverTimestamp(),
    MovementFields.status: MovementStatus.active.wire,
    MovementFields.seenBy: [movement.createdBy],
  };

  /// Changes of a movement rejected by [uid].
  static Map<String, Object?> reject({
    required String uid,
    required RejectReason reason,
    String? note,
  }) => {
    MovementFields.status: MovementStatus.rejected.wire,
    MovementFields.rejectedAt: FieldValue.serverTimestamp(),
    MovementFields.rejectedBy: uid,
    MovementFields.rejectReason: reason.wire,
    MovementFields.rejectNote: note,
    MovementFields.seenBy: FieldValue.arrayUnion([uid]),
  };

  /// Changes of a movement deleted by its author (soft delete).
  static Map<String, Object?> softDelete() => {
    MovementFields.status: MovementStatus.deleted.wire,
    MovementFields.deletedAt: FieldValue.serverTimestamp(),
  };

  /// [uid] opened the movement.
  static Map<String, Object?> markSeen(String uid) => {
    MovementFields.seenBy: FieldValue.arrayUnion([uid]),
  };

  /// An entry of `groups/{groupId}/auditLog`.
  static Map<String, Object?> auditEntry({
    required String action,
    required String movementId,
    required String uid,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) => {
    AuditLogFields.action: action,
    AuditLogFields.entity: MovementFields.auditEntity,
    AuditLogFields.entityId: movementId,
    AuditLogFields.before: before,
    AuditLogFields.after: after,
    AuditLogFields.uid: uid,
    AuditLogFields.timestamp: FieldValue.serverTimestamp(),
  };

  static List<PaymentApplication> _applications(Object? value) {
    if (value is! List) return const [];
    return [
      for (final item in value)
        if (item is Map &&
            item[MovementFields.targetId] is String &&
            item[MovementFields.amount] is int &&
            (item[MovementFields.amount] as int) > 0)
          PaymentApplication(
            targetId: item[MovementFields.targetId] as String,
            amount: item[MovementFields.amount] as int,
          ),
    ];
  }

  static AccountSnapshot? _account(Object? value) {
    if (value is! Map) return null;
    return AccountSnapshot(
      type: PaymentAccountType.fromWire(value[MovementFields.accountType]),
      name: value[MovementFields.accountName] as String? ?? '',
      reference: value[MovementFields.accountReference] as String? ?? '',
    );
  }

  static MovementAttachment? _attachment(Object? value) {
    if (value is! Map) return null;
    final url = value[MovementFields.attachmentUrl];
    if (url is! String || url.isEmpty) return null;
    int number(String key) => value[key] is int ? value[key] as int : 0;
    return MovementAttachment(
      url: url,
      width: number(MovementFields.attachmentWidth),
      height: number(MovementFields.attachmentHeight),
      bytes: number(MovementFields.attachmentBytes),
    );
  }

  static DateTime? _date(Object? value) =>
      value is Timestamp ? value.toDate() : null;
}
