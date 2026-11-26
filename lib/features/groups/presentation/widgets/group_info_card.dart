import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../../../home/presentation/dialogs/code_box.dart';
import '../../../home/presentation/home_metrics.dart';
import '../../../home/presentation/home_strings.dart';
import '../../../home/presentation/home_text_styles.dart';
import '../../../home/presentation/widgets/group_mosaic.dart';
import '../../../profile/data/profile_providers.dart';
import '../../domain/group.dart';
import '../groups_metrics.dart';
import '../groups_strings.dart';
import '../member_dates.dart';

/// Summary of a group: mosaic, size, creation date, admin, its settings,
/// the join code (copyable) and whether the Home shows it.
class GroupInfoCard extends ConsumerWidget {
  const GroupInfoCard({
    super.key,
    required this.group,
    required this.index,
    required this.uid,
    required this.isShownInHome,
    required this.onShowInHome,
  });

  final Group group;

  /// Position in the user's groups; picks the mosaic colors.
  final int index;
  final String uid;
  final bool isShownInHome;
  final VoidCallback onShowInHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final createdAt = group.createdAt;
    final String admin;
    if (group.isAdmin(uid)) {
      admin = GroupsStrings.youAdminGroup;
    } else {
      final nickname = ref
          .watch(userProfileProvider(group.ownerUid))
          .value
          ?.nickname;
      final others = group.adminUids.where((u) => u != group.ownerUid).length;
      admin = nickname == null
          ? ''
          : others == 0
          ? GroupsStrings.adminBy(nickname)
          : GroupsStrings.adminByMany(nickname, others);
    }
    final tags = [
      if (group.requiresApproval) GroupsStrings.requiresApproval,
      if (group.hasPassword) GroupsStrings.withPassword,
    ];

    return Container(
      padding: EdgeInsets.all(tokens.space2),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GroupMosaic(initials: group.initials, index: index),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeStrings.members(group.memberCount),
                      style: styles.rowTitle,
                    ),
                    if (createdAt != null)
                      Text(
                        GroupsStrings.createdOn(MemberDates.format(createdAt)),
                        style: styles.detail,
                      ),
                    if (admin.isNotEmpty) Text(admin, style: styles.detail),
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            SizedBox(height: tokens.space2),
            Wrap(
              spacing: tokens.space1,
              runSpacing: tokens.space1,
              children: [for (final tag in tags) _Tag(label: tag)],
            ),
          ],
          SizedBox(height: tokens.space2),
          CodeBox(code: group.code),
          SizedBox(height: tokens.space2),
          if (isShownInHome)
            Row(
              children: [
                Icon(
                  Icons.check,
                  size: GroupsMetrics.checkSize,
                  color: tokens.positive,
                ),
                SizedBox(width: tokens.space1),
                Expanded(
                  child: Text(
                    GroupsStrings.shownInHome,
                    style: styles.cardText,
                  ),
                ),
              ],
            )
          else
            FbuSecondaryButton(
              onPressed: onShowInHome,
              child: const Text(GroupsStrings.showInHome),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GroupsMetrics.tagPaddingH,
        vertical: GroupsMetrics.tagPaddingV,
      ),
      decoration: BoxDecoration(
        color: tokens.textPrimary.withValues(
          alpha: HomeMetrics.chipFillOpacity,
        ),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Text(label, style: HomeTextStyles.of(context).small),
    );
  }
}
