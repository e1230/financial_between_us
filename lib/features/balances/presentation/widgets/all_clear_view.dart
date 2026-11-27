import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';

/// "Todo en orden": nobody owes the user and they owe nobody.
class AllClearView extends StatelessWidget {
  const AllClearView({super.key, required this.scopeName});

  final String scopeName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space3),
      child: MergeSemantics(
        child: Column(
          children: [
            Container(
              width: BalancesMetrics.allClearCircle,
              height: BalancesMetrics.allClearCircle,
              decoration: BoxDecoration(
                color: tokens.positive.withValues(
                  alpha: BalancesMetrics.semanticTint,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: BalancesMetrics.allClearIcon,
                color: tokens.positive,
              ),
            ),
            SizedBox(height: tokens.space2),
            Text(BalancesStrings.allClearTitle, style: styles.emptyTitle),
            SizedBox(height: tokens.space1),
            Text(
              BalancesStrings.allClearText(scopeName),
              textAlign: TextAlign.center,
              style: styles.body,
            ),
          ],
        ),
      ),
    );
  }
}
