import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../data/balances_providers.dart';
import '../../domain/ledger_movement.dart';
import '../../domain/movement_validators.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/pill_choice.dart';
import 'movement_failure_message.dart';

/// Asks why [movement] is rejected and rejects it. Completes with `true`
/// once rejected.
Future<bool> showRejectDialog(
  BuildContext context, {
  required LedgerMovement movement,
  required String me,
  required String otherFirstName,
}) async =>
    await showFbuDialog<bool>(
      context: context,
      builder: (_) => RejectDialog(
        movement: movement,
        me: me,
        otherFirstName: otherFirstName,
      ),
    ) ??
    false;

/// "¿Rechazar el pago de {Nombre}?": what happens, the reason ("No me
/// llegó" by default, "Monto equivocado", "Otro motivo" with an optional
/// note of up to 80 characters) and "Cancelar" / "Rechazar".
class RejectDialog extends ConsumerStatefulWidget {
  const RejectDialog({
    super.key,
    required this.movement,
    required this.me,
    required this.otherFirstName,
  });

  final LedgerMovement movement;
  final String me;
  final String otherFirstName;

  @override
  ConsumerState<RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends ConsumerState<RejectDialog> {
  RejectReason _reason = RejectReason.notReceived;
  final TextEditingController _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _reject() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(movementActionsProvider)
          .reject(
            movement: widget.movement,
            me: widget.me,
            reason: _reason,
            note: _reason == RejectReason.other ? _note.text : null,
          );
      // TODO: FCM — tell the author ("{name} rechazó tu pago de $ X").
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = movementFailureMessage(error);
        });
      }
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final m = widget.movement;
    final first = widget.otherFirstName;
    final title = m.isPayment
        ? BalancesStrings.rejectPaymentTitle(first)
        : BalancesStrings.rejectDebtTitle(first);
    final text = m.isPayment
        ? BalancesStrings.rejectPaymentText(first, m.amount)
        : BalancesStrings.rejectDebtText(first, m.amount);
    final buttonStyle = TextButton.styleFrom(
      minimumSize: const Size(0, BalancesMetrics.touchTarget),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    final error = _error;

    return FbuDialog(
      semanticsLabel: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(header: true, child: Text(title, style: styles.sheetTitle)),
          SizedBox(height: tokens.space1),
          Text(text, style: styles.sheetSubtitle),
          SizedBox(height: tokens.space2),
          Text(BalancesStrings.reasonLabel, style: styles.sectionLabel),
          SizedBox(height: tokens.space1),
          Wrap(
            spacing: tokens.space1,
            children: [
              for (final reason in RejectReason.values)
                PillChoice(
                  label: rejectReasonLabel(reason),
                  selected: reason == _reason,
                  height: BalancesMetrics.filterHeight,
                  onTap: _busy ? null : () => setState(() => _reason = reason),
                ),
            ],
          ),
          if (_reason == RejectReason.other) ...[
            SizedBox(height: tokens.space1),
            TextField(
              controller: _note,
              enabled: !_busy,
              maxLength: MovementValidators.maxRejectNoteLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: BalancesStrings.otherReasonHint,
              ),
            ),
          ],
          if (error != null) ...[
            SizedBox(height: tokens.space1),
            Semantics(
              liveRegion: true,
              child: Text(
                error,
                style: styles.body.copyWith(color: tokens.negative),
              ),
            ),
          ],
          SizedBox(height: tokens.space2),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: tokens.space1,
            children: [
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                style: buttonStyle.copyWith(
                  foregroundColor: WidgetStatePropertyAll(tokens.textPrimary),
                ),
                child: const Text(BalancesStrings.cancel),
              ),
              TextButton(
                onPressed: _busy ? null : _reject,
                style: buttonStyle.copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                    _busy ? tokens.textDisabled : tokens.negative,
                  ),
                ),
                child: const Text(BalancesStrings.reject),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reason of a rejection, as the dialog and the detail show it.
String rejectReasonLabel(RejectReason reason) => switch (reason) {
  RejectReason.notReceived => BalancesStrings.reasonNotReceived,
  RejectReason.wrongAmount => BalancesStrings.reasonWrongAmount,
  RejectReason.other => BalancesStrings.reasonOther,
};
