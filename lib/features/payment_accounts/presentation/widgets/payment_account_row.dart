import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/payment_account.dart';
import '../../domain/payment_account_rules.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import 'payment_account_logo.dart';

/// One account of the list: name and formatted reference on the left, the
/// logo on the right.
///
/// Tap opens the detail; a long press copies the reference ([onCopy]) and,
/// when there is one, lights the row up for 400 ms. Screen readers also get
/// a "Copiar referencia" action.
class PaymentAccountRow extends StatefulWidget {
  const PaymentAccountRow({
    super.key,
    required this.account,
    required this.onOpen,
    required this.onCopy,
  });

  final PaymentAccount account;
  final VoidCallback onOpen;
  final VoidCallback onCopy;

  @override
  State<PaymentAccountRow> createState() => _PaymentAccountRowState();
}

class _PaymentAccountRowState extends State<PaymentAccountRow> {
  bool _highlighted = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _copy() {
    widget.onCopy();
    if (!widget.account.hasReference) return;
    _timer?.cancel();
    setState(() => _highlighted = true);
    _timer = Timer(PaymentAccountsMetrics.rowHighlight, () {
      if (mounted) setState(() => _highlighted = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final account = widget.account;
    final reference = account.hasReference
        ? PaymentAccountRules.displayReference(account)
        : PaymentAccountsStrings.cashReference;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      label: PaymentAccountsStrings.rowLabel(account),
      hint: PaymentAccountsStrings.rowHint,
      customSemanticsActions: {
        const CustomSemanticsAction(label: PaymentAccountsStrings.copyAction):
            _copy,
      },
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onOpen,
          onLongPress: _copy,
          // The copy vibrates on its own (and cash must not vibrate).
          enableFeedback: false,
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : PaymentAccountsMetrics.rowHighlightFade,
            color: _highlighted
                ? tokens.surfaceVariant
                : tokens.surfaceVariant.withValues(alpha: 0),
            constraints: const BoxConstraints(
              minHeight: PaymentAccountsMetrics.rowMinHeight,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: PaymentAccountsMetrics.rowPaddingV,
              horizontal: PaymentAccountsMetrics.rowPaddingH,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.rowName,
                      ),
                      const SizedBox(height: PaymentAccountsMetrics.rowTextGap),
                      Text(
                        reference,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: styles.rowReference,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PaymentAccountsMetrics.rowGap),
                PaymentAccountLogo(type: account.type),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
