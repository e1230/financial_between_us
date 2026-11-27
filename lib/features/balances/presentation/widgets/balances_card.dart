import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../balances_metrics.dart';

/// A `surface` card of radius 12 whose [children] are separated by 1 dp
/// `border` dividers indented 68 dp (past the 40 dp icon).
class BalancesCard extends StatelessWidget {
  const BalancesCard({
    super.key,
    required this.children,
    this.dividerInset = BalancesMetrics.dividerInset,
  });

  final List<Widget> children;
  final double dividerInset;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: dividerInset,
                color: tokens.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
