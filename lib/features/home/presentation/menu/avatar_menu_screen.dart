import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../groups/data/groups_providers.dart';
import '../../../profile/data/profile_providers.dart';
import '../../data/home_providers.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';
import '../widgets/ring_avatar.dart';
import 'menu_option_tile.dart';
import 'sign_out_dialog.dart';

/// Full-page menu opened from the avatar. The avatar flies here as a Hero
/// (44 → 64 dp) while the rest fades in and rises 16 dp.
class AvatarMenuScreen extends ConsumerWidget {
  const AvatarMenuScreen({super.key});

  // DECISIÓN: shown until package_info_plus answers (or if it fails).
  static const String fallbackVersion = '1.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final profile = ref.watch(currentUserProfileProvider).value;
    final groups = ref.watch(myGroupsProvider).value ?? const [];
    final active = ref.watch(activeGroupProvider).value;
    final version = ref.watch(appVersionProvider).value ?? fallbackVersion;
    final divider = Divider(height: 1, thickness: 1, color: tokens.border);

    void close() => Navigator.of(context).maybePop();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        divider,
        MenuOptionTile(
          icon: Icons.people_outline,
          title: HomeStrings.menuGroups,
          description: HomeStrings.menuGroupsText(
            active?.name,
            groups.length - (active == null ? 0 : 1),
          ),
          onTap: () => context.push(AppRoutes.groups),
        ),
        divider,
        MenuOptionTile(
          icon: Icons.credit_card_outlined,
          title: HomeStrings.accounts,
          description: HomeStrings.menuAccountsText,
          onTap: () => context.push(AppRoutes.accounts),
        ),
        divider,
        MenuOptionTile(
          icon: Icons.calendar_today_outlined,
          title: HomeStrings.menuEvents,
          description: HomeStrings.menuEventsText,
          onTap: () => context.go(AppRoutes.events),
        ),
        divider,
        MenuOptionTile(
          icon: Icons.balance_outlined,
          title: HomeStrings.menuBalances,
          description: HomeStrings.menuBalancesText,
          onTap: () => context.go(AppRoutes.balances),
        ),
        divider,
        MenuOptionTile(
          icon: Icons.logout,
          title: HomeStrings.signOut,
          destructive: true,
          onTap: () => showSignOutDialog(context),
        ),
        divider,
      ],
    );

    return Scaffold(
      backgroundColor: tokens.menuBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: padding.top + HomeMetrics.menuProfileTop,
                bottom: padding.bottom + tokens.space3,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      padding.vertical -
                      HomeMetrics.menuProfileTop -
                      tokens.space3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () => context.push(AppRoutes.profileSettings),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: HomeMetrics.menuProfileMinHeight,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.space3,
                            vertical: HomeMetrics.actionPadding,
                          ),
                          child: Row(
                            children: [
                              HeroMode(
                                enabled: !reduceMotion,
                                child: Hero(
                                  tag: RingAvatar.heroTag,
                                  flightShuttleBuilder: _shuttle,
                                  child: SizedBox.square(
                                    dimension: HomeMetrics.menuAvatarSize,
                                    child: RingAvatar(profile: profile),
                                  ),
                                ),
                              ),
                              SizedBox(width: tokens.space2),
                              Expanded(
                                child: _MenuEntrance(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile?.displayName ?? '',
                                        style: styles.menuName,
                                      ),
                                      Text(
                                        '@${profile?.nickname ?? ''}',
                                        style: styles.menuNickname.copyWith(
                                          color: context.userPalette.userSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: HomeMetrics.menuChevronSize,
                                color: tokens.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: tokens.space3),
                    _MenuEntrance(child: content),
                    SizedBox(height: tokens.space6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: tokens.space3),
                      child: Text(
                        HomeStrings.version(version),
                        style: styles.footer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: padding.top + HomeMetrics.headerTopGap,
            left: HomeMetrics.menuCloseInset,
            child: IconButton(
              onPressed: close,
              tooltip: HomeStrings.closeMenu,
              icon: Icon(
                Icons.close,
                size: HomeMetrics.menuIconSize,
                color: tokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The flying avatar: a [RingAvatar] that resizes with the flight, so the
  /// ring gap and the initial interpolate between both sizes.
  static Widget _shuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) => Consumer(
    builder: (context, ref, _) =>
        RingAvatar(profile: ref.watch(currentUserProfileProvider).value),
  );
}

/// Fade + 16 dp rise of the menu content, driven by the route animation
/// (300 ms after a 100 ms delay, ease-out cubic).
class _MenuEntrance extends StatelessWidget {
  const _MenuEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.animation;
    if (route == null || MediaQuery.disableAnimationsOf(context)) return child;
    final total = HomeMetrics.menuTransition.inMilliseconds;
    final start = HomeMetrics.menuContentDelay.inMilliseconds / total;
    final end =
        (HomeMetrics.menuContentDelay + HomeMetrics.menuContentDuration)
            .inMilliseconds /
        total;
    final curved = CurvedAnimation(
      parent: route,
      curve: Interval(start, end, curve: HomeMetrics.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, HomeMetrics.menuContentOffset * (1 - curved.value)),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
