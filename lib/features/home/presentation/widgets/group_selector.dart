import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../groups/data/groups_providers.dart';
import '../../../groups/domain/group.dart';
import '../../../profile/data/profile_providers.dart';
import '../dialogs/create_group_dialog.dart';
import '../dialogs/join_group_dialog.dart';
import '../home_metrics.dart';
import 'group_pill.dart';
import 'group_selector_panel.dart';

/// The group pill of the header and the floating selector it opens, drawn
/// in the overlay over a 50 % black barrier (the pill stays on top).
class GroupSelector extends ConsumerStatefulWidget {
  const GroupSelector({super.key});

  @override
  ConsumerState<GroupSelector> createState() => _GroupSelectorState();
}

class _GroupSelectorState extends ConsumerState<GroupSelector>
    with SingleTickerProviderStateMixin {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: HomeMetrics.crossfade,
  );

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Duration get _duration => MediaQuery.disableAnimationsOf(context)
      ? HomeMetrics.reducedMotionFade
      : context.tokens.motionShort;

  void _open() {
    _animation.duration = _duration;
    _portal.show();
    _animation.forward();
    setState(() {});
  }

  Future<void> _close() async {
    _animation.duration = _duration;
    setState(() {});
    await _animation.reverse();
    if (mounted) _portal.hide();
  }

  Future<void> _select(Group group) async {
    await _close();
    await ref.read(selectedGroupIdProvider.notifier).select(group.id);
  }

  Future<void> _then(Future<void> Function(BuildContext) dialog) async {
    await _close();
    if (mounted) await dialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeGroupProvider).value;
    final open =
        _portal.isShowing && _animation.status != AnimationStatus.reverse;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: GroupPill(
          groupName: active?.name,
          expanded: open,
          onTap: open ? _close : _open,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final groups = ref.watch(myGroupsProvider).value ?? const <Group>[];
    final active = ref.watch(activeGroupProvider).value;
    final uid = ref.watch(currentUserProfileProvider).value?.uid ?? '';
    final screen = MediaQuery.sizeOf(context);
    final width = screen.width - tokens.space2 * 2;
    final maxHeight = screen.height * HomeMetrics.selectorMaxHeightFactor;
    final curved = CurvedAnimation(
      parent: _animation,
      curve: HomeMetrics.easeOutCubic,
    );

    return BackButtonListener(
      onBackButtonPressed: () async {
        await _close();
        return true;
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _animation,
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: tokens.brandBackground.withValues(
                    alpha: HomeMetrics.selectorBarrierOpacity,
                  ),
                ),
              ),
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: const Offset(0, HomeMetrics.selectorGap),
            child: SizedBox(
              width: width,
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  alignment: Alignment.topCenter,
                  scale: reduceMotion
                      ? const AlwaysStoppedAnimation(1)
                      : Tween(
                          begin: HomeMetrics.selectorStartScale,
                          end: 1.0,
                        ).animate(curved),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: GroupSelectorPanel(
                      groups: groups,
                      activeGroupId: active?.id,
                      uid: uid,
                      onSelect: _select,
                      onCreate: () => _then(showCreateGroupDialog),
                      onJoin: () => _then(showJoinGroupDialog),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // The pill again, above the barrier.
          CompositedTransformFollower(
            link: _link,
            child: GroupPill(
              groupName: active?.name,
              expanded: true,
              onTap: _close,
            ),
          ),
        ],
      ),
    );
  }
}
