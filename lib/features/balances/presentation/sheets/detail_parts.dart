import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_pill_button.dart';
import '../balances_metrics.dart';
import '../balances_text_styles.dart';

/// A 48 dp label / value row of the detail box.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: BalancesMetrics.detailRowHeight,
        ),
        child: Row(
          children: [
            Text(label, style: styles.rowDetail),
            SizedBox(width: tokens.space2),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: value),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Rechazar" / "Eliminar": `surfaceVariant` pill with red text and icon.
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return FbuPillButton(
      onPressed: onPressed,
      colors: FbuPillButtonColors(
        background: tokens.surfaceVariant,
        pressedBackground: tokens.border,
        disabledBackground: tokens.surfaceVariant,
        foreground: tokens.negative,
        disabledForeground: tokens.textDisabled,
        ripple: tokens.negative.withValues(alpha: FbuPillButton.rippleOpacity),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize, color: tokens.negative),
          SizedBox(width: tokens.space1),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
