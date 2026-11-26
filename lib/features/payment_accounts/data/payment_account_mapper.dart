import 'package:cloud_firestore/cloud_firestore.dart';

import '../../groups/data/group_mapper.dart' show AuditLogFields;
import '../domain/payment_account.dart';

/// Field names of `users/{uid}/paymentAccounts/{accountId}`.
abstract final class PaymentAccountFields {
  static const String name = 'name';
  static const String type = 'type';

  /// Only for Bre-B; `null` otherwise.
  static const String keyType = 'keyType';

  /// Without format; empty for cash.
  static const String reference = 'reference';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String deletedAt = 'deletedAt';

  /// `entity` of their `auditLog` entries.
  static const String auditEntity = 'paymentAccount';
}

/// Converts payment account documents to domain objects and back.
abstract final class PaymentAccountMapper {
  /// Reads a payment account. Missing values fall back to safe defaults so
  /// an old or partial document never crashes the app.
  static PaymentAccount fromFirestore(String id, Map<String, dynamic> data) {
    final type = PaymentAccountType.fromWire(data[PaymentAccountFields.type]);
    return PaymentAccount(
      id: id,
      name: data[PaymentAccountFields.name] as String? ?? '',
      type: type,
      keyType: type == PaymentAccountType.breb
          ? BrebKeyType.fromWire(data[PaymentAccountFields.keyType])
          : null,
      reference: type == PaymentAccountType.cash
          ? ''
          : data[PaymentAccountFields.reference] as String? ?? '',
      createdAt: _date(data[PaymentAccountFields.createdAt]),
      updatedAt: _date(data[PaymentAccountFields.updatedAt]),
      deletedAt: _date(data[PaymentAccountFields.deletedAt]),
    );
  }

  /// The editable fields of [account], as stored.
  static Map<String, Object?> content(PaymentAccount account) => {
    PaymentAccountFields.name: account.name.trim(),
    PaymentAccountFields.type: account.type.wire,
    PaymentAccountFields.keyType: account.type == PaymentAccountType.breb
        ? account.keyType?.wire
        : null,
    PaymentAccountFields.reference: account.type == PaymentAccountType.cash
        ? ''
        : account.reference,
  };

  /// Document of a new account.
  static Map<String, Object?> create(PaymentAccount account) => {
    ...content(account),
    PaymentAccountFields.createdAt: FieldValue.serverTimestamp(),
    PaymentAccountFields.updatedAt: FieldValue.serverTimestamp(),
    PaymentAccountFields.deletedAt: null,
  };

  /// Changes of an edited account.
  static Map<String, Object?> update(PaymentAccount account) => {
    ...content(account),
    PaymentAccountFields.updatedAt: FieldValue.serverTimestamp(),
  };

  /// Changes of a deleted account (soft delete).
  static Map<String, Object?> softDelete() => {
    PaymentAccountFields.deletedAt: FieldValue.serverTimestamp(),
    PaymentAccountFields.updatedAt: FieldValue.serverTimestamp(),
  };

  /// An entry of `users/{uid}/auditLog`, with the same keys as the group
  /// log.
  static Map<String, Object?> auditEntry({
    required String action,
    required String accountId,
    required String uid,
    Map<String, Object?>? before,
    Map<String, Object?>? after,
  }) => {
    AuditLogFields.action: action,
    AuditLogFields.entity: PaymentAccountFields.auditEntity,
    AuditLogFields.entityId: accountId,
    AuditLogFields.before: before,
    AuditLogFields.after: after,
    AuditLogFields.uid: uid,
    AuditLogFields.timestamp: FieldValue.serverTimestamp(),
  };

  static DateTime? _date(Object? value) =>
      value is Timestamp ? value.toDate() : null;
}
