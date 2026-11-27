import 'package:freezed_annotation/freezed_annotation.dart';

import '../../payment_accounts/domain/payment_account.dart';

part 'ledger_movement.freezed.dart';

/// What a [LedgerMovement] records. The `wire` value is what Firestore
/// stores.
enum LedgerMovementType {
  /// Someone owes someone else ("Registrar deuda", or a share of an event).
  debt('debt'),

  /// Someone paid (part of) what they owed.
  payment('payment');

  const LedgerMovementType(this.wire);

  final String wire;

  /// The type stored as [value], or `null` if missing or unknown.
  static LedgerMovementType? fromWire(Object? value) {
    for (final t in values) {
      if (t.wire == value) return t;
    }
    return null;
  }
}

/// Where a debt comes from.
enum DebtKind {
  /// A share of an event (an outing whose bill was split).
  event('event'),

  /// Registered by hand, without an event ("deuda natural").
  direct('direct');

  const DebtKind(this.wire);

  final String wire;

  /// The kind stored as [value]; anything unknown is [direct].
  static DebtKind fromWire(Object? value) =>
      values.firstWhere((k) => k.wire == value, orElse: () => direct);
}

/// Life cycle of a movement. Only [active] ones count for the balance.
enum MovementStatus {
  active('active'),

  /// The other party rejected it. Final: to fix it, register another one.
  rejected('rejected'),

  /// Its author deleted it (soft delete).
  deleted('deleted');

  const MovementStatus(this.wire);

  final String wire;

  /// The status stored as [value]; anything unknown counts as [deleted], so
  /// a newer status never adds money to a balance.
  static MovementStatus fromWire(Object? value) =>
      values.firstWhere((s) => s.wire == value, orElse: () => deleted);
}

/// Why a movement was rejected.
enum RejectReason {
  notReceived('not_received'),
  wrongAmount('wrong_amount'),
  other('other');

  const RejectReason(this.wire);

  final String wire;

  /// The reason stored as [value], or `null` if missing or unknown.
  static RejectReason? fromWire(Object? value) {
    for (final r in values) {
      if (r.wire == value) return r;
    }
    return null;
  }
}

/// Part of a payment that settles the pending item [targetId]: a debt id, or
/// the id of a credit (see `PendingItem.creditIdFor`).
@freezed
abstract class PaymentApplication with _$PaymentApplication {
  const factory PaymentApplication({
    required String targetId,

    /// Whole pesos, always positive.
    required int amount,
  }) = _PaymentApplication;
}

/// Copy of the payment account a payment went to, as it was when the
/// payment was registered (not a live reference: accounts can change).
@freezed
abstract class AccountSnapshot with _$AccountSnapshot {
  const factory AccountSnapshot({
    required PaymentAccountType type,
    required String name,

    /// Without format; empty for cash.
    @Default('') String reference,
  }) = _AccountSnapshot;
}

/// Image attached to a movement (a receipt or a photo), stored in
/// Cloudinary.
@freezed
abstract class MovementAttachment with _$MovementAttachment {
  const factory MovementAttachment({
    /// Cloudinary `secure_url`.
    required String url,
    @Default(0) int width,
    @Default(0) int height,

    /// Size of the uploaded file.
    @Default(0) int bytes,
  }) = _MovementAttachment;
}

/// A debt or a payment between two members of a group
/// (`groups/{groupId}/movements/{id}`).
///
/// Balances are computed from the active movements (see `PairLedger`),
/// never stored. Movements are never edited: they are rejected by the other
/// party or deleted by their author, and a new one is registered.
@freezed
abstract class LedgerMovement with _$LedgerMovement {
  const factory LedgerMovement({
    required String id,
    required String groupId,
    required LedgerMovementType type,

    /// Who owes (in a payment: who pays).
    required String debtorUid,

    /// Who is owed (in a payment: who receives).
    required String creditorUid,

    /// Whole pesos (COP), always positive.
    required int amount,

    /// Only for debts.
    @Default(DebtKind.direct) DebtKind kind,

    /// Only for debts of an event.
    String? eventId,
    String? eventName,

    /// Debt: what it was for ("Taxi"). Payment: empty.
    @Default('') String concept,

    /// Only for payments: which pending items it settles.
    @Default(<PaymentApplication>[]) List<PaymentApplication> appliedTo,

    /// Only for payments: where the money went.
    AccountSnapshot? account,
    String? note,
    MovementAttachment? attachment,

    /// When it happened (chosen by the user).
    required DateTime date,
    required String createdBy,

    /// Set by the server; `null` while a local write is pending.
    DateTime? createdAt,
    @Default(MovementStatus.active) MovementStatus status,
    DateTime? rejectedAt,
    String? rejectedBy,
    RejectReason? rejectReason,
    String? rejectNote,
    DateTime? deletedAt,

    /// Users who already opened it (for the "new" dot).
    @Default(<String>[]) List<String> seenBy,
  }) = _LedgerMovement;

  const LedgerMovement._();

  bool get isDebt => type == LedgerMovementType.debt;
  bool get isPayment => type == LedgerMovementType.payment;
  bool get isActive => status == MovementStatus.active;
  bool get isRejected => status == MovementStatus.rejected;
  bool get isDeleted => status == MovementStatus.deleted;

  /// Both parties, for `array-contains` queries.
  List<String> get participants => [debtorUid, creditorUid];

  /// The pair of parties, for the history queries (see [pairKeyOf]).
  String get pairKey => pairKeyOf(debtorUid, creditorUid);

  bool involves(String uid) => uid == debtorUid || uid == creditorUid;

  /// The party that is not [uid].
  String otherParty(String uid) => uid == debtorUid ? creditorUid : debtorUid;

  /// The party that did not register it: the one who may reject it.
  String get recipientUid => otherParty(createdBy);

  /// Only the recipient rejects, and only while it is active.
  bool canReject(String uid) => isActive && involves(uid) && uid != createdBy;

  /// Only its author deletes it, and only while it is active.
  bool canDelete(String uid) => isActive && uid == createdBy;

  /// Registered by the other party and not opened yet by [uid].
  bool isNewFor(String uid) =>
      !isDeleted && involves(uid) && createdBy != uid && !seenBy.contains(uid);

  /// Sum of [appliedTo].
  int get appliedTotal => appliedTo.fold(0, (sum, a) => sum + a.amount);
}

/// Chronological order of movements: by [LedgerMovement.date], then by
/// creation (undated last), then by id, so every device computes the same
/// balance.
int compareChronologically(LedgerMovement a, LedgerMovement b) {
  final byDate = a.date.compareTo(b.date);
  if (byDate != 0) return byDate;
  final far = DateTime.utc(9999);
  final byCreation = (a.createdAt ?? far).compareTo(b.createdAt ?? far);
  if (byCreation != 0) return byCreation;
  return a.id.compareTo(b.id);
}

/// Key of the pair [a]–[b], the same in both orders: the two uids sorted
/// and joined with `_` (Firebase uids never contain it).
String pairKeyOf(String a, String b) =>
    a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
