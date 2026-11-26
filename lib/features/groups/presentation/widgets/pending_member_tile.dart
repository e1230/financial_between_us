import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../home/presentation/home_text_styles.dart';
import '../../../profile/data/profile_providers.dart';
import '../../domain/group_member.dart';
import '../groups_metrics.dart';
import '../groups_strings.dart';
import '../member_dates.dart';
import 'member_avatar.dart';

/// A pending request: avatar, name and when they asked. The admin gets
/// "Aprobar" and "Rechazar" (both receive the visible name).
class PendingMemberTile extends ConsumerWidget {
  const PendingMemberTile({
    super.key,
    required this.member,
    this.busy = false,
    this.onApprove,
    this.onReject,
  });

  final GroupMember member;

  /// An action on this request is running: buttons disabled, spinner.
  final bool busy;
  final ValueChanged<String>? onApprove;
  final ValueChanged<String>? onReject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final profile = ref.watch(userProfileProvider(member.uid)).value;
    final name = profile?.displayName ?? '';
    final requestedAt = member.joinedAt;
    final onApprove = this.onApprove;
    final onReject = this.onReject;

    final info = Row(
      children: [
        MemberAvatar(profile: profile),
        SizedBox(width: tokens.space2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: styles.rowTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                [
                  if (profile != null) '@${profile.nickname}',
                  if (requestedAt != null)
                    GroupsStrings.requestedOn(MemberDates.format(requestedAt)),
                ].join(' · '),
                style: styles.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    if (onApprove == null || onReject == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space1),
        child: info,
      );
    }

    final buttonStyle = TextButton.styleFrom(
      minimumSize: const Size(0, GroupsMetrics.requestButtonHeight),
      padding: EdgeInsets.symmetric(horizontal: tokens.space2),
      shape: const StadiumBorder(),
      textStyle: styles.chip,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.space1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          info,
          SizedBox(height: tokens.space1),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: tokens.space1,
            runSpacing: tokens.space1,
            children: [
              Semantics(
                label: GroupsStrings.rejectOf(name),
                button: true,
                excludeSemantics: true,
                child: TextButton(
                  onPressed: busy ? null : () => onReject(name),
                  style: buttonStyle.copyWith(
                    foregroundColor: WidgetStatePropertyAll(tokens.negative),
                  ),
                  child: const Text(GroupsStrings.reject),
                ),
              ),
              Semantics(
                label: GroupsStrings.approveOf(name),
                button: true,
                excludeSemantics: true,
                child: TextButton(
                  onPressed: busy ? null : () => onApprove(name),
                  style: buttonStyle.copyWith(
                    backgroundColor: WidgetStatePropertyAll(tokens.accent),
                    foregroundColor: WidgetStatePropertyAll(tokens.onAccent),
                  ),
                  child: busy
                      ? SizedBox.square(
                          dimension: GroupsMetrics.checkSize,
                          child: CircularProgressIndicator(
                            strokeWidth: GroupsMetrics.spinnerStroke,
                            color: tokens.onAccent,
                            semanticsLabel: GroupsStrings.approving,
                          ),
                        )
                      : const Text(GroupsStrings.approve),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
