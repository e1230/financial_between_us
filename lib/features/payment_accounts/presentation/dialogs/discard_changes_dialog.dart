import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';

/// "¿Descartar los cambios?" Completes with `true` to discard them.
Future<bool> showDiscardChangesDialog(BuildContext context) async =>
    await showFbuDialog<bool>(
      context: context,
      builder: (_) => const DiscardChangesDialog(),
    ) ??
    false;

class DiscardChangesDialog extends StatelessWidget {
  const DiscardChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final buttonStyle = TextButton.styleFrom(
      minimumSize: const Size(0, PaymentAccountsMetrics.touchTarget),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    return FbuDialog(
      semanticsLabel: PaymentAccountsStrings.discardTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              PaymentAccountsStrings.discardTitle,
              style: styles.dialogTitle,
            ),
          ),
          SizedBox(height: tokens.space2),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: tokens.space1,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: buttonStyle.copyWith(
                  foregroundColor: WidgetStatePropertyAll(tokens.textPrimary),
                ),
                child: const Text(PaymentAccountsStrings.keepEditing),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: buttonStyle.copyWith(
                  foregroundColor: WidgetStatePropertyAll(tokens.negative),
                ),
                child: const Text(PaymentAccountsStrings.discard),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
