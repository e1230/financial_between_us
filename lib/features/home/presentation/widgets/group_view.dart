import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../profile/data/profile_providers.dart';
import '../../data/home_providers.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import 'activity_chart.dart';
import 'activity_legend.dart';
import 'greeting.dart';
import 'period_chips.dart';
import 'quick_action_button.dart';
import 'recent_movements.dart';

/// Home content of the active group: greeting, period, chart, quick actions
/// and latest movements.
class GroupView extends ConsumerWidget {
  const GroupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final profile = ref.watch(currentUserProfileProvider).value;
    final series = ref.watch(activitySeriesProvider).value;
    // The chips have a 48 dp touch target around their 32 dp; the extra
    // space comes out of the gaps above and below.
    const chipSlack = (HomeMetrics.touchTarget - HomeMetrics.chipHeight) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Greeting(name: profile?.displayName ?? ''),
        const SizedBox(height: HomeMetrics.chipsGap - chipSlack),
        const PeriodChips(),
        const SizedBox(height: HomeMetrics.legendGap - chipSlack),
        ActivityLegend(series: series),
        const SizedBox(height: HomeMetrics.chartGap),
        if (series == null)
          Semantics(
            label: HomeStrings.loadingChart,
            child: const SizedBox(
              height: HomeMetrics.chartHeight + HomeMetrics.chartAxisHeight,
            ),
          )
        else
          ActivityChart(series: series),
        const SizedBox(height: HomeMetrics.actionsGap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: Icons.south_west,
                  label: HomeStrings.addIncome,
                  onTap: () => context.push(AppRoutes.newIncome),
                ),
              ),
              const SizedBox(width: HomeMetrics.actionGap),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.north_east,
                  label: HomeStrings.addPayment,
                  onTap: () => context.push(AppRoutes.newPayment),
                ),
              ),
              const SizedBox(width: HomeMetrics.actionGap),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.schedule,
                  label: HomeStrings.addDebt,
                  onTap: () => context.push(AppRoutes.newDebt),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space2),
        const RecentMovements(),
      ],
    );
  }
}
