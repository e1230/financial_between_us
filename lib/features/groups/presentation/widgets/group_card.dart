import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../home/presentation/home_metrics.dart';
import '../../../home/presentation/home_strings.dart';
import '../../../home/presentation/home_text_styles.dart';
import '../../../home/presentation/widgets/group_mosaic.dart';
import '../../domain/group.dart';
import '../groups_metrics.dart';
import '../groups_strings.dart';

/// A group of the "Grupos" page: mosaic, name, size and role, join code and
/// the leave action ("Cancelar solicitud" while pending). Tapping an active
/// group opens its detail; the one shown in the Home has a check.
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.index,
    required this.uid,
    required this.isShownInHome,
    required this.onOpen,
    required this.onLeave,
  });

  final Group group;

  /// Position in the list; picks the mosaic colors.
  final int index;
  final String uid;
  final bool isShownInHome;
  final VoidCallback onOpen;
  final VoidCallback onLeave;

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

    final info = Row(
      children: [
        Opacity(
          opacity: pending ? HomeMetrics.selectorPendingOpacity : 1,
          child: GroupMosaic(initials: group.initials, index: index),
        ),
        SizedBox(width: tokens.space2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      group.name,
                      style: styles.rowTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isShownInHome) ...[
                    SizedBox(width: tokens.space1),
                    Icon(
                      Icons.check,
                      size: GroupsMetrics.checkSize,
                      color: tokens.positive,
                      semanticLabel: GroupsStrings.shownInHome,
                    ),
                  ],
                ],
              ),
              Text(
                detail,
                style: styles.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!pending)
                Text(
                  GroupsStrings.code(group.code),
                  style: styles.small,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );

    return Material(
      color: isShownInHome ? tokens.surfaceVariant : tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        side: BorderSide(color: tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: GroupsMetrics.cardMinHeight,
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                button: !pending,
                selected: isShownInHome,
                hint: pending ? null : GroupsStrings.openDetail,
                child: InkWell(
                  onTap: pending ? null : onOpen,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      tokens.space2,
                      tokens.space2,
                      0,
                      tokens.space2,
                    ),
                    child: info,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.space1),
              child: IconButton(
                onPressed: onLeave,
                tooltip: pending
                    ? GroupsStrings.cancelRequest
                    : GroupsStrings.leave,
                icon: Icon(
                  pending ? Icons.close : Icons.logout,
                  size: GroupsMetrics.actionIconSize,
                  color: tokens.negative,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
