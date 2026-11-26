import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_account.freezed.dart';

/// Where a user receives payments.
///
/// The `wire` value is what Firestore stores.
// DECISIÓN: stored in English, like the other enums in Firestore
// (`active`, `pending`); the labels shown to the user live in the
// presentation layer.
enum PaymentAccountType {
  breb('breb'),
  nequi('nequi'),
  daviplata('daviplata'),
  cash('cash'),
  other('other');

  const PaymentAccountType(this.wire);

  final String wire;

  /// Order of the type tiles in the form.
  static const List<PaymentAccountType> formOrder = [
    breb,
    nequi,
    daviplata,
    cash,
    other,
  ];

  /// The type stored as [value]; anything unknown is [other], so a newer
  /// type never breaks an older app.
  static PaymentAccountType fromWire(Object? value) =>
      values.firstWhere((t) => t.wire == value, orElse: () => other);

  /// Nequi and Daviplata are mobile wallets tied to a phone number.
  bool get isWallet => this == nequi || this == daviplata;
}

/// Kind of a Bre-B key.
enum BrebKeyType {
  phone('phone'),
  email('email'),
  document('document'),
  alias('alias');

  const BrebKeyType(this.wire);

  final String wire;

  /// The key type stored as [value], or `null` if missing or unknown.
  static BrebKeyType? fromWire(Object? value) {
    for (final t in values) {
      if (t.wire == value) return t;
    }
    return null;
  }
}

/// A payment account of a user (`users/{uid}/paymentAccounts/{id}`).
///
/// Accounts belong to the user, not to a group: the same ones show up in
/// every group they are in.
@freezed
abstract class PaymentAccount with _$PaymentAccount {
  const factory PaymentAccount({
    required String id,

    /// Name chosen by the user, like "Nequi personal".
    required String name,
    required PaymentAccountType type,

    /// Only for [PaymentAccountType.breb].
    BrebKeyType? keyType,

    /// Without format: only digits for phones and documents. Empty for
    /// [PaymentAccountType.cash].
    required String reference,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _PaymentAccount;

  const PaymentAccount._();

  /// Whether there is something to copy (cash has no reference).
  bool get hasReference => type != PaymentAccountType.cash;
}
