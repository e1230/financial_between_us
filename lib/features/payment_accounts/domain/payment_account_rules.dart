import 'payment_account.dart';

/// Why a name is not valid.
enum NameError { empty, tooLong }

/// Why a reference is not valid (table 6.4 of the spec).
enum ReferenceError {
  /// Nothing written.
  empty,

  /// A phone without 10 digits.
  phoneLength,

  /// A phone that does not start with 3.
  phonePrefix,

  /// A malformed email key.
  email,

  /// A document key without 6 to 10 digits.
  document,

  /// An alias key that is not `@` plus 3 to 20 letters, digits, `.`, `_`
  /// or `-`.
  alias,

  /// "Otro" with fewer than 4 characters.
  tooShort,
}

/// What the reference holds for a type (and key type), which decides its
/// keyboard, filter and validation.
enum ReferenceKind { phone, email, document, alias, free, none }

/// Pure rules of payment accounts: validation, normalization and display.
abstract final class PaymentAccountRules {
  /// Soft limit of accounts per user.
  // DECISIÓN: 10, as suggested by the spec; adjustable.
  static const int maxAccounts = 10;
  static const int nameMaxLength = 40;
  static const int phoneLength = 10;
  static const String phonePrefix = '3';
  static const int documentMinLength = 6;
  static const int documentMaxLength = 10;
  static const int otherMinLength = 4;

  /// Longest reference the security rules accept.
  static const int referenceMaxLength = 64;

  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
  );
  static final RegExp _alias = RegExp(r'^@[A-Za-z0-9._-]{3,20}$');
  static final RegExp _nonDigits = RegExp(r'\D');

  /// What the reference of [type] holds; [keyType] only matters for Bre-B,
  /// where `null` (not chosen yet) gives [ReferenceKind.none].
  static ReferenceKind kindOf(PaymentAccountType? type, BrebKeyType? keyType) =>
      switch (type) {
        null || PaymentAccountType.cash => ReferenceKind.none,
        PaymentAccountType.nequi ||
        PaymentAccountType.daviplata => ReferenceKind.phone,
        PaymentAccountType.other => ReferenceKind.free,
        PaymentAccountType.breb => switch (keyType) {
          null => ReferenceKind.none,
          BrebKeyType.phone => ReferenceKind.phone,
          BrebKeyType.email => ReferenceKind.email,
          BrebKeyType.document => ReferenceKind.document,
          BrebKeyType.alias => ReferenceKind.alias,
        },
      };

  /// `null` when [name] is valid (1 to 40 characters once trimmed).
  static NameError? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return NameError.empty;
    if (trimmed.length > nameMaxLength) return NameError.tooLong;
    return null;
  }

  /// `null` when [raw] is a valid reference of [kind].
  static ReferenceError? validateReference(ReferenceKind kind, String raw) {
    final value = normalizeReference(kind, raw);
    if (kind == ReferenceKind.none) return null;
    if (value.isEmpty) return ReferenceError.empty;
    return switch (kind) {
      ReferenceKind.phone =>
        value.length != phoneLength
            ? ReferenceError.phoneLength
            : !value.startsWith(phonePrefix)
            ? ReferenceError.phonePrefix
            : null,
      ReferenceKind.email =>
        _email.hasMatch(value) ? null : ReferenceError.email,
      ReferenceKind.document =>
        value.length < documentMinLength || value.length > documentMaxLength
            ? ReferenceError.document
            : null,
      ReferenceKind.alias =>
        _alias.hasMatch(value) ? null : ReferenceError.alias,
      ReferenceKind.free =>
        value.length < otherMinLength ? ReferenceError.tooShort : null,
      ReferenceKind.none => null,
    };
  }

  /// [raw] as stored: only digits for phones and documents, trimmed for
  /// the rest, empty for [ReferenceKind.none].
  static String normalizeReference(ReferenceKind kind, String raw) =>
      switch (kind) {
        ReferenceKind.phone ||
        ReferenceKind.document => raw.replaceAll(_nonDigits, ''),
        ReferenceKind.none => '',
        ReferenceKind.email ||
        ReferenceKind.alias ||
        ReferenceKind.free => raw.trim(),
      };

  /// [reference] for display: a 10-digit phone as `300 123 4567`; anything
  /// else as it is.
  static String formatReference(ReferenceKind kind, String reference) {
    if (kind != ReferenceKind.phone || reference.length != phoneLength) {
      return reference;
    }
    return '${reference.substring(0, 3)} '
        '${reference.substring(3, 6)} '
        '${reference.substring(6)}';
  }

  /// [ReferenceKind] of a stored [account].
  static ReferenceKind kindOfAccount(PaymentAccount account) =>
      account.type == PaymentAccountType.breb && account.keyType == null
      // An old Bre-B account without key type: shown as typed.
      ? ReferenceKind.free
      : kindOf(account.type, account.keyType);

  /// Formatted reference of [account] (empty for cash).
  static String displayReference(PaymentAccount account) =>
      formatReference(kindOfAccount(account), account.reference);

  /// First word of [displayName], to sign shared texts.
  static String firstName(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
