import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/payment_account.dart';
import '../../domain/payment_account_rules.dart';
import '../payment_accounts_strings.dart';

/// Label, placeholder, keyboard and input filters of the "Referencia"
/// field for the chosen type and key type (table 6.4 of the spec).
@immutable
class ReferenceInput {
  const ReferenceInput._({
    required this.kind,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.formatters,
    this.helper,
  });

  factory ReferenceInput.of(PaymentAccountType? type, BrebKeyType? keyType) {
    final kind = PaymentAccountRules.kindOf(type, keyType);
    final isBreb = type == PaymentAccountType.breb;
    final digits = FilteringTextInputFormatter.digitsOnly;
    return switch (kind) {
      ReferenceKind.phone => ReferenceInput._(
        kind: kind,
        label: isBreb
            ? PaymentAccountsStrings.keyFieldLabel
            : PaymentAccountsStrings.phoneFieldLabel,
        hint: PaymentAccountsStrings.phoneHint,
        keyboardType: TextInputType.phone,
        formatters: [
          digits,
          LengthLimitingTextInputFormatter(PaymentAccountRules.phoneLength),
        ],
      ),
      ReferenceKind.email => ReferenceInput._(
        kind: kind,
        label: PaymentAccountsStrings.keyFieldLabel,
        hint: PaymentAccountsStrings.emailHint,
        keyboardType: TextInputType.emailAddress,
        formatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(
            PaymentAccountRules.referenceMaxLength,
          ),
        ],
      ),
      ReferenceKind.document => ReferenceInput._(
        kind: kind,
        label: PaymentAccountsStrings.keyFieldLabel,
        hint: PaymentAccountsStrings.documentHint,
        keyboardType: TextInputType.number,
        formatters: [
          digits,
          LengthLimitingTextInputFormatter(
            PaymentAccountRules.documentMaxLength,
          ),
        ],
      ),
      ReferenceKind.alias => ReferenceInput._(
        kind: kind,
        label: PaymentAccountsStrings.keyFieldLabel,
        hint: PaymentAccountsStrings.aliasHint,
        keyboardType: TextInputType.text,
        helper: PaymentAccountsStrings.aliasHelper,
        formatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(
            PaymentAccountRules.referenceMaxLength,
          ),
        ],
      ),
      ReferenceKind.free => ReferenceInput._(
        kind: kind,
        label: PaymentAccountsStrings.otherFieldLabel,
        hint: PaymentAccountsStrings.otherHint,
        keyboardType: TextInputType.text,
        formatters: [
          LengthLimitingTextInputFormatter(
            PaymentAccountRules.referenceMaxLength,
          ),
        ],
      ),
      ReferenceKind.none => ReferenceInput._(
        kind: kind,
        label: isBreb
            ? PaymentAccountsStrings.keyFieldLabel
            : PaymentAccountsStrings.referenceFieldLabel,
        hint: isBreb
            ? PaymentAccountsStrings.referenceNoKey
            : PaymentAccountsStrings.referenceNoType,
        keyboardType: TextInputType.text,
        formatters: const [],
      ),
    };
  }

  final ReferenceKind kind;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatters;

  /// Shown under the field while it has no error.
  final String? helper;

  /// The field can be typed in (a type and, for Bre-B, a key type chosen).
  bool get enabled => kind != ReferenceKind.none;
}
