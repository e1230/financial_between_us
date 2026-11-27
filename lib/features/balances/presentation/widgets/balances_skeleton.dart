import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';

/// The summary card and three rows as placeholders while balances load.
class BalancesSkeleton extends StatelessWidget {
  const BalancesSkeleton({super.key});

  static const int _rows = 3;
  static const double _summaryHeight = 196;
  static const double _line = 12;
  static const double _nameWidth = 0.6;
  static const double _detailWidth = 0.4;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget bar(double width) => Container(
      width: width,
      height: _line,
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
    );
    return Semantics(
      label: BalancesStrings.loading,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: _summaryHeight,
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radiusPanel),
              ),
            ),
            const SizedBox(height: BalancesMetrics.sectionGap),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radiusCard),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _rows; i++)
                    SizedBox(
                      height: BalancesMetrics.rowMinHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: BalancesMetrics.rowPaddingH,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: BalancesMetrics.avatar,
                              height: BalancesMetrics.avatar,
                              decoration: BoxDecoration(
                                color: tokens.surfaceVariant,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: BalancesMetrics.rowGap),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, c) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    bar(c.maxWidth * _nameWidth),
                                    SizedBox(height: tokens.space1),
                                    bar(c.maxWidth * _detailWidth),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
