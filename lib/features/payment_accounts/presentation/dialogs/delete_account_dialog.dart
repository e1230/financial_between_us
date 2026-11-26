import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../auth/data/auth_providers.dart';
import '../../data/payment_accounts_providers.dart';
import '../../domain/payment_account.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import 'account_failure_message.dart';

/// Asks before deleting [account] and deletes it (soft delete) on confirm.
/// Completes with `true` once deleted.
Future<bool> showDeleteAccountDialog(
  BuildContext context,
  PaymentAccount account,
) async =>
    await showFbuDialog<bool>(
      context: context,
      builder: (_) => DeleteAccountDialog(account: account),
    ) ??
    false;

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key, required this.account});

  final PaymentAccount account;

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _delete() async {
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(paymentAccountsRepositoryProvider)
          .delete(uid: uid, account: widget.account);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = accountFailureMessage(error);
        });
      }
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final title = PaymentAccountsStrings.deleteTitle(widget.account.name);
    final error = _error;
    final buttonStyle = TextButton.styleFrom(
      minimumSize: const Size(0, PaymentAccountsMetrics.touchTarget),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    return FbuDialog(
      semanticsLabel: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: styles.dialogTitle),
          ),
          SizedBox(height: tokens.space1),
          Text(PaymentAccountsStrings.deleteText, style: styles.dialogText),
          if (error != null) ...[
            SizedBox(height: tokens.space2),
            Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: styles.dialogText.copyWith(color: tokens.negative),
              ),
            ),
          ],
          SizedBox(height: tokens.space2),
          // Right-aligned; wraps instead of overflowing with large text.
          Wrap(
            alignment: WrapAlignment.end,
            spacing: tokens.space1,
            children: [
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                style: buttonStyle.copyWith(
                  foregroundColor: WidgetStatePropertyAll(tokens.textPrimary),
                ),
                child: const Text(PaymentAccountsStrings.cancel),
              ),
              TextButton(
                onPressed: _busy ? null : _delete,
                style: buttonStyle.copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                    _busy ? tokens.textDisabled : tokens.negative,
                  ),
                ),
                child: const Text(PaymentAccountsStrings.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
