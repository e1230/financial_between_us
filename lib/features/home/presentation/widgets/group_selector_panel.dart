import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../groups/domain/group.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';
import 'group_mosaic.dart';

/// Content of the floating group selector: the user's groups (the active
/// one checked, pending ones disabled) and the create / join actions.
class GroupSelectorPanel extends StatelessWidget {
  const GroupSelectorPanel({
    super.key,
    required this.groups,
    required this.activeGroupId,
    required this.uid,
    required this.onSelect,
    required this.onCreate,
    required this.onJoin,
  });

  final List<Group> groups;
  final String? activeGroupId;
  final String uid;
  final ValueChanged<Group> onSelect;
  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    return Material(
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusPanel),
        side: BorderSide(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(HomeMetrics.selectorPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space2,
                tokens.space1,
                tokens.space2,
                tokens.space1,
              ),
              child: Semantics(
                header: true,
                child: Text(HomeStrings.yourGroups, style: styles.overline),
              ),
            ),
            if (groups.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.space2,
                  vertical: tokens.space1,
                ),
                child: Text(HomeStrings.noGroupsYet, style: styles.detail),
              )
            else
              for (final (index, group) in groups.indexed)
                _GroupRow(
                  group: group,
                  index: index,
                  uid: uid,
                  isActive: group.id == activeGroupId,
                  onTap: () => onSelect(group),
                ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: HomeMetrics.selectorDividerMarginV,
                horizontal: HomeMetrics.selectorDividerMarginH,
              ),
              child: Divider(height: 1, thickness: 1, color: tokens.border),
            ),
            _ActionRow(
              icon: Icons.add,
              label: HomeStrings.createGroup,
              onTap: onCreate,
            ),
            _ActionRow(
              icon: Icons.login,
              label: HomeStrings.joinWithCode,
              onTap: onJoin,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.group,
    required this.index,
    required this.uid,
    required this.isActive,
    required this.onTap,
  });

  final Group group;
  final int index;
  final String uid;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final pending = group.isPending(uid);
    final detail = [
      HomeStrings.members(group.memberCount),
      if (pending)
        HomeStrings.awaitingApproval
      else if (group.isAdmin(uid))
        HomeStrings.youAdmin,
    ].join(' · ');

    final row = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: HomeMetrics.selectorRowHeight,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space2,
          vertical: tokens.space1,
        ),
        child: Row(
          children: [
            GroupMosaic(initials: group.initials, index: index),
            SizedBox(width: tokens.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    group.name,
                    style: styles.rowTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    detail,
                    style: styles.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isActive) ...[
              SizedBox(width: tokens.space1),
              Icon(
                Icons.check,
                size: HomeMetrics.selectorCheckSize,
                color: tokens.positive,
              ),
            ],
          ],
        ),
      ),
    );

    return Semantics(
      selected: isActive,
      enabled: !pending,
      button: true,
      child: Opacity(
        opacity: pending ? HomeMetrics.selectorPendingOpacity : 1,
        child: Material(
          color: isActive ? tokens.surfaceVariant : tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: pending ? null : onTap, child: row),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: tokens.surface,
      borderRadius: BorderRadius.circular(tokens.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: HomeMetrics.selectorActionHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.space2),
            child: Row(
              children: [
                SizedBox(
                  width: HomeMetrics.selectorTile,
                  child: Icon(
                    icon,
                    size: HomeMetrics.iconSize,
                    color: tokens.textPrimary,
                  ),
                ),
                SizedBox(width: tokens.space2),
                Expanded(
                  child: Text(
                    label,
                    style: HomeTextStyles.of(context).rowTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
