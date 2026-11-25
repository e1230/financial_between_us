import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/home_providers.dart';
import '../../domain/activity_period.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// "Semana", "Mes" and "6 meses": the period of the chart.
class PeriodChips extends ConsumerWidget {
  const PeriodChips({super.key});

  static String label(ActivityPeriod period) => switch (period) {
    ActivityPeriod.week => HomeStrings.periodWeek,
    ActivityPeriod.month => HomeStrings.periodMonth,
    ActivityPeriod.sixMonths => HomeStrings.periodSixMonths,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final selected = ref.watch(selectedPeriodProvider);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: HomeStrings.periodLabel,
      container: true,
      child: Wrap(
        spacing: tokens.space1,
        children: [
          for (final period in ActivityPeriod.values)
            Semantics(
              inMutuallyExclusiveGroup: true,
              checked: period == selected,
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(selectedPeriodProvider.notifier).select(period),
                // 48 dp touch target around the 32 dp chip.
                child: SizedBox(
                  height: HomeMetrics.touchTarget,
                  child: Center(
                    widthFactor: 1,
                    child: AnimatedContainer(
                      duration: reduceMotion
                          ? Duration.zero
                          : tokens.motionFast,
                      height: HomeMetrics.chipHeight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: HomeMetrics.chipPadding,
                      ),
                      decoration: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: period == selected
                            ? tokens.textPrimary
                            : tokens.textPrimary.withValues(
                                alpha: HomeMetrics.chipFillOpacity,
                              ),
                      ),
                      // Hugs the label; Container.alignment would stretch it.
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          label(period),
                          style: styles.chip.copyWith(
                            color: period == selected
                                ? tokens.onAccent
                                : tokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
