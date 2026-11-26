import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../../home/presentation/home_text_styles.dart';
import '../../../profile/data/profile_providers.dart';
import '../../domain/group_member.dart';
import '../groups_metrics.dart';
import '../groups_strings.dart';
import '../member_dates.dart';
import 'member_avatar.dart';

/// An active member: avatar, name, nickname and role, since when, and the
/// user's balance with them. The admin sees a remove button on the others.
class MemberTile extends ConsumerWidget {
  const MemberTile({
    super.key,
    required this.member,
    required this.isMe,
    required this.balance,
    this.onRemove,
  });

  final GroupMember member;
  final bool isMe;

  /// The user's balance with this member (see `balancesWith`): positive
  /// "Te debe", negative "Debes", zero "Están a mano". `null` hides it
  /// (own row, or while balances load).
  final int? balance;

  /// Called with the member's visible name; `null` hides the button.
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final profile = ref.watch(userProfileProvider(member.uid)).value;
    final name = profile?.displayName ?? '';
    final role = member.role == MemberRole.admin
        ? GroupsStrings.roleAdmin
        : GroupsStrings.roleMember;
    final joinedAt = member.joinedAt;
    final onRemove = this.onRemove;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: GroupsMetrics.memberMinHeight,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space1),
        child: Row(
          children: [
            MemberAvatar(profile: profile),
            SizedBox(width: tokens.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isMe ? GroupsStrings.you(name) : name,
                    style: styles.rowTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    [
                      if (profile != null) '@${profile.nickname}',
                      role,
                    ].join(' · '),
                    style: styles.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (joinedAt != null)
                    Text(
                      GroupsStrings.since(MemberDates.format(joinedAt)),
                      style: styles.small,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (balance case final balance?) ...[
              SizedBox(width: tokens.space2),
              // Only as wide as it needs (the name takes the rest), capped
              // so large fonts wrap the label and shrink the amount instead
              // of overflowing.
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: GroupsMetrics.balanceMaxWidth,
                ),
                child: BalanceLabel(balance: balance),
              ),
            ],
            if (onRemove != null)
              IconButton(
                onPressed: () => onRemove(name),
                tooltip: GroupsStrings.removeMember,
                icon: Icon(
                  Icons.person_remove_outlined,
                  size: GroupsMetrics.actionIconSize,
                  color: tokens.negative,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Te debe / $ 32.000" in green, "Debes / $ 41.500" in red, or "Están a
/// mano".
class BalanceLabel extends StatelessWidget {
  const BalanceLabel({super.key, required this.balance});

  /// Positive: they owe the user. Negative: the user owes them.
  final int balance;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    if (balance == 0) {
      return Text(
        GroupsStrings.even,
        style: styles.detail,
        textAlign: TextAlign.end,
      );
    }
    final owesYou = balance > 0;
    final color = owesYou ? tokens.positive : tokens.negative;
    final label = owesYou ? GroupsStrings.owesYou : GroupsStrings.youOwe;
    final amount = MoneyFormat.format(balance);
    return Semantics(
      label: '$label $amount',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: styles.small.copyWith(color: color),
            textAlign: TextAlign.end,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(amount, style: styles.rowAmount.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
