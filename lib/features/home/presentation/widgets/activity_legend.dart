import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../../core/utils/money_format.dart';
import '../../domain/activity_period.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// The three series of the chart with their current amounts.
class ActivityLegend extends StatelessWidget {
  const ActivityLegend({super.key, required this.series});

  /// `null` while loading (amounts show as "—").
  final ActivitySeries? series;

  static const String placeholder = '—';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final data = series;
    String amount(int Function(ActivitySeries) of) =>
        data == null ? placeholder : MoneyFormat.format(of(data));
    return ExcludeSemantics(
      // The chart announces the same values.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Entry(
              color: context.userPalette.userSoft,
              label: HomeStrings.paid,
              amount: amount((s) => s.paidTotal),
            ),
          ),
          const SizedBox(width: HomeMetrics.legendColumnGap),
          Expanded(
            child: _Entry(
              color: tokens.positive,
              label: HomeStrings.owedToYou,
              amount: amount((s) => s.owedToYouNow),
            ),
          ),
          const SizedBox(width: HomeMetrics.legendColumnGap),
          Expanded(
            child: _Entry(
              color: tokens.negative,
              label: HomeStrings.youOwe,
              amount: amount((s) => s.youOweNow),
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.color,
    required this.label,
    required this.amount,
  });

  final Color color;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final styles = HomeTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: HomeMetrics.legendDot,
              height: HomeMetrics.legendDot,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: HomeMetrics.legendDotGap),
            Flexible(
              child: Text(
                label,
                style: styles.legendLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: HomeMetrics.legendLineGap),
        // Never wraps: scales down instead.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(amount, style: styles.legendAmount, maxLines: 1),
        ),
      ],
    );
  }
}
