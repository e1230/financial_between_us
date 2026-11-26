import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/payment_account.dart';
import '../../domain/payment_account_rules.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';

/// Dark box of the detail with the reference, labeled by type: "NÚMERO DE
/// CELULAR" for wallets, a key chip for Bre-B, "REFERENCIA" for the rest,
/// and a short explanation for cash.
class ReferenceBox extends StatelessWidget {
  const ReferenceBox({super.key, required this.account});

  final PaymentAccount account;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);

    final List<Widget> children;
    if (!account.hasReference) {
      children = [
        Text(PaymentAccountsStrings.cashTitle, style: styles.cashTitle),
        Text(PaymentAccountsStrings.cashText, style: styles.cashText),
      ];
    } else {
      final value = PaymentAccountRules.displayReference(account);
      final keyType = account.keyType;
      final Widget label;
      final String labelText;
      if (account.type == PaymentAccountType.breb && keyType != null) {
        labelText = PaymentAccountsStrings.keyChip(keyType);
        label = Container(
          padding: const EdgeInsets.symmetric(
            vertical: PaymentAccountsMetrics.chipPaddingV,
            horizontal: PaymentAccountsMetrics.chipPaddingH,
          ),
          decoration: ShapeDecoration(
            color: tokens.surfaceVariant,
            shape: const StadiumBorder(),
          ),
          child: Text(labelText, style: styles.chip),
        );
      } else {
        labelText = account.type.isWallet
            ? PaymentAccountsStrings.phoneLabel
            : PaymentAccountsStrings.referenceLabel;
        label = Text(labelText, style: styles.boxLabel);
      }
      final long = value.length > PaymentAccountsMetrics.longValueLength;
      children = [
        Align(alignment: AlignmentDirectional.centerStart, child: label),
        // The raw value is read aloud (not the spaced one).
        Semantics(
          label: account.reference,
          excludeSemantics: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              style: long ? styles.valueSmall : styles.value,
            ),
          ),
        ),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(PaymentAccountsMetrics.boxPadding),
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(PaymentAccountsMetrics.boxRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: PaymentAccountsMetrics.boxInnerGap,
        children: children,
      ),
    );
  }
}
