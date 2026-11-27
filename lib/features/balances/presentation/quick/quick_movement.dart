import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/fbu_toast.dart';
import '../balances_format.dart';
import '../balances_strings.dart';
import '../sheets/register_debt_sheet.dart';
import '../sheets/register_payment_sheet.dart';
import 'person_picker_sheet.dart';
import 'quick_movement_kind.dart';

/// Registers a movement from the Home: first the person (in the active
/// group), then the same payment or debt sheet as the person detail.
// DECISIÓN: the Home actions ask for the person first because every
// movement is between two people; "Ingreso" only offers people who owe the
// user and "Pago" people the user owes, since a payment settles what is
// pending.
Future<void> startQuickMovement(
  BuildContext context,
  QuickMovementKind kind,
) async {
  final picked = await showPersonPicker(context, kind: kind);
  if (picked == null || !context.mounted) return;
  final first = PersonNames.first(picked.profile);

  final String? message;
  switch (kind) {
    case QuickMovementKind.income:
    case QuickMovementKind.payment:
      final theyPayMe = kind == QuickMovementKind.income;
      final result = await showRegisterPaymentSheet(
        context,
        me: picked.me,
        otherUid: picked.uid,
        otherFirstName: first,
        theyPayMe: theyPayMe,
        pendings: picked.ledger.pendingsOwedBy(
          theyPayMe ? picked.uid : picked.me,
        ),
      );
      message = result == null
          ? null
          : BalancesStrings.paymentRegistered(result.amount);
    case QuickMovementKind.debt:
      final id = await showRegisterDebtSheet(
        context,
        me: picked.me,
        otherUid: picked.uid,
        otherFullName: PersonNames.full(picked.profile),
        otherFirstName: first,
        groups: [DebtGroupOption(id: picked.group.id, name: picked.group.name)],
      );
      message = id == null ? null : BalancesStrings.debtRegistered;
  }
  if (message == null || !context.mounted) return;
  await HapticFeedback.lightImpact();
  if (context.mounted) {
    // Above the bottom bar of the shell.
    FbuToast.show(context, message, position: FbuToastPosition.aboveActions);
  }
}
