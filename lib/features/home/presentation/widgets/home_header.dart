import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../profile/data/profile_providers.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import 'group_selector.dart';
import 'ring_avatar.dart';

/// Top row of the Home: avatar (opens the menu), group selector and
/// accounts button.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      height: HomeMetrics.headerHeight,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: HomeStrings.openMenu,
            excludeSemantics: true,
            child: _CircleTap(
              onTap: () => context.push(AppRoutes.menu),
              child: _HeaderAvatarHero(reduceMotion: reduceMotion),
            ),
          ),
          SizedBox(width: tokens.space1),
          const Expanded(child: Center(child: GroupSelector())),
          SizedBox(width: tokens.space1),
          Tooltip(
            message: HomeStrings.accounts,
            child: _CircleTap(
              onTap: () => context.push(AppRoutes.accounts),
              child: Container(
                width: HomeMetrics.headerAvatarSize,
                height: HomeMetrics.headerAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.textPrimary.withValues(
                    alpha: HomeMetrics.glassFillOpacity,
                  ),
                  border: Border.all(
                    color: tokens.textPrimary.withValues(
                      alpha: HomeMetrics.glassBorderOpacity,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.credit_card_outlined,
                  size: HomeMetrics.headerIconSize,
                  color: tokens.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The header avatar as the Hero of the menu.
///
/// It only takes part in flights while Inicio is visible (its tickers are
/// on): the profile tab has its own avatar Hero with the same tag.
///
/// Opening the menu leaves this Hero as a hidden placeholder until a flight
/// comes back to it. When the menu closes elsewhere (to Perfil, Eventos or
/// Saldos) nothing does, so each time Inicio becomes visible again the Hero
/// is rebuilt from scratch, without the placeholder.
class _HeaderAvatarHero extends StatefulWidget {
  const _HeaderAvatarHero({required this.reduceMotion});

  final bool reduceMotion;

  @override
  State<_HeaderAvatarHero> createState() => _HeaderAvatarHeroState();
}

class _HeaderAvatarHeroState extends State<_HeaderAvatarHero> {
  bool _visible = true;
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (visible && !_visible) _generation++;
    _visible = visible;
  }

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: !widget.reduceMotion && _visible,
      child: Hero(
        key: ValueKey(_generation),
        tag: RingAvatar.heroTag,
        child: const SizedBox.square(
          dimension: HomeMetrics.headerAvatarSize,
          child: _HeaderAvatar(),
        ),
      ),
    );
  }
}

/// Keeps the avatar in sync with the profile without rebuilding the Hero.
class _HeaderAvatar extends ConsumerWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      RingAvatar(profile: ref.watch(currentUserProfileProvider).value);
}

/// A circular 48 dp touch target around a smaller visual.
class _CircleTap extends StatelessWidget {
  const _CircleTap({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: HomeMetrics.touchTarget,
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
