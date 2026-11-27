import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../balances_metrics.dart';
import '../balances_text_styles.dart';

/// A pill option of a group where only one is selected (quick amounts,
/// history filters, reasons, groups): white with dark text when
/// [selected], `surfaceVariant` otherwise. At least 48 dp to touch.
class PillChoice extends StatelessWidget {
  const PillChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = BalancesMetrics.quickChipHeight,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: BalancesMetrics.touchTarget,
          ),
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: reduceMotion
                  ? BalancesMetrics.reducedFade
                  : BalancesMetrics.chipSwap,
              height: height,
              padding: const EdgeInsets.symmetric(
                horizontal: BalancesMetrics.filterPaddingH,
              ),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: selected ? tokens.textPrimary : tokens.surfaceVariant,
                shape: const StadiumBorder(),
              ),
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: styles.tab.copyWith(
                  color: selected ? tokens.background : tokens.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
