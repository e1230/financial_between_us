import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../../data/home_providers.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';
import 'movement_skeleton.dart';
import 'movement_tile.dart';

/// "Últimos movimientos" of the active group, with its loading, empty and
/// error states.
class RecentMovements extends ConsumerWidget {
  const RecentMovements({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final movements = ref.watch(recentMovementsProvider);
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: tokens.textPrimary.withValues(
        alpha: HomeMetrics.movementDividerOpacity,
      ),
    );

    final Widget body = switch (movements) {
      AsyncValue(:final value?) when value.isEmpty => Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space2),
        child: Text(HomeStrings.noMovements, style: styles.cardText),
      ),
      AsyncValue(:final value?) => Column(
        children: [
          for (final (i, movement) in value.indexed) ...[
            if (i > 0) divider,
            MovementTile(movement: movement),
          ],
        ],
      ),
      AsyncValue(hasError: true) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.space1),
          const AuthBanner(message: HomeStrings.movementsError),
          TextButton(
            onPressed: () => ref.invalidate(recentMovementsProvider),
            child: const Text(HomeStrings.retry),
          ),
        ],
      ),
      _ => const MovementSkeleton(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  HomeStrings.recentTitle,
                  style: styles.sectionTitle,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: HomeMetrics.touchTarget,
              ),
              child: TextButton(
                onPressed: () => context.go(AppRoutes.balances),
                style: TextButton.styleFrom(
                  foregroundColor: tokens.positive,
                  textStyle: styles.link,
                  minimumSize: const Size(
                    HomeMetrics.touchTarget,
                    HomeMetrics.touchTarget,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: tokens.space1),
                ),
                child: const Text(HomeStrings.seeAll),
              ),
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : tokens.motionFast,
          child: KeyedSubtree(
            key: ValueKey(movements.runtimeType),
            child: body,
          ),
        ),
      ],
    );
  }
}
