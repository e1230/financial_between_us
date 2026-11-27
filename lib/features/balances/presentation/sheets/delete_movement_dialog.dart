import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../data/balances_providers.dart';
import '../../domain/ledger_movement.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import 'movement_failure_message.dart';

/// Asks before deleting [movement] (soft delete) and deletes it. Completes
/// with `true` once deleted.
Future<bool> showDeleteMovementDialog(
  BuildContext context, {
  required LedgerMovement movement,
  required String me,
}) async =>
    await showFbuDialog<bool>(
      context: context,
      builder: (_) => _DeleteMovementDialog(movement: movement, me: me),
    ) ??
    false;

class _DeleteMovementDialog extends ConsumerStatefulWidget {
  const _DeleteMovementDialog({required this.movement, required this.me});

  final LedgerMovement movement;
  final String me;

  @override
  ConsumerState<_DeleteMovementDialog> createState() =>
      _DeleteMovementDialogState();
}

class _DeleteMovementDialogState extends ConsumerState<_DeleteMovementDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(movementActionsProvider)
          .delete(movement: widget.movement, me: widget.me);
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
    final buttonStyle = TextButton.styleFrom(
      minimumSize: const Size(0, BalancesMetrics.touchTarget),
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    final error = _error;
    return FbuDialog(
      semanticsLabel: BalancesStrings.deleteTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(BalancesStrings.deleteTitle, style: styles.sheetTitle),
          ),
          SizedBox(height: tokens.space1),
          Text(BalancesStrings.deleteText, style: styles.sheetSubtitle),
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
                onPressed: _busy ? null : _delete,
                style: buttonStyle.copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                    _busy ? tokens.textDisabled : tokens.negative,
                  ),
                ),
                child: const Text(BalancesStrings.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
