import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import '../../auth/presentation/widgets/auth_banner.dart';
import '../../groups/data/groups_providers.dart';
import 'home_metrics.dart';
import 'home_strings.dart';
import 'widgets/arc_background.dart';
import 'widgets/group_view.dart';
import 'widgets/home_header.dart';
import 'widgets/movement_skeleton.dart';
import 'widgets/no_groups_view.dart';

/// "Inicio": the arc, the header and the content of the active group (or
/// the invitation to create or join one). The bottom bar belongs to the
/// shell, which extends this body behind it.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final padding = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final active = ref.watch(activeGroupProvider);
    final headerTop = padding.top + HomeMetrics.headerTopGap;
    final contentTop = headerTop + HomeMetrics.headerHeight;
    // The 44 dp header circles sit in 48 dp touch targets.
    final headerInset =
        tokens.space2 -
        (HomeMetrics.touchTarget - HomeMetrics.headerAvatarSize) / 2;

    final Widget content = switch (active) {
      AsyncValue(hasValue: true, :final value) =>
        value == null
            ? const NoGroupsView(key: ValueKey('no-groups'))
            : GroupView(key: ValueKey(value.id)),
      AsyncValue(hasError: true) => _GroupsError(
        key: const ValueKey('error'),
        onRetry: () => ref.invalidate(myGroupsProvider),
      ),
      _ => const MovementSkeleton(key: ValueKey('loading')),
    };

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ArcBackground()),
          Positioned(
            top: contentTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  HomeMetrics.contentPadding,
                  HomeMetrics.contentGap,
                  HomeMetrics.contentPadding,
                  padding.bottom + tokens.space2,
                ),
                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? HomeMetrics.reducedMotionFade
                      : HomeMetrics.crossfade,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  child: content,
                ),
              ),
            ),
          ),
          Positioned(
            top: headerTop,
            left: headerInset,
            right: headerInset,
            child: const HomeHeader(),
          ),
        ],
      ),
    );
  }
}

class _GroupsError extends StatelessWidget {
  const _GroupsError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthBanner(message: HomeStrings.groupsError),
        TextButton(onPressed: onRetry, child: const Text(HomeStrings.retry)),
      ],
    );
  }
}
