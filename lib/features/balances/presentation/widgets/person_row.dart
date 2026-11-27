import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../../profile/data/profile_providers.dart';
import '../../domain/balances_overview.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import 'person_avatar.dart';

/// A person of the balances list: avatar, name, "@usuario · detail" and,
/// on the right, the amount over "te debe" / "le debes" / "a paz y salvo".
/// The amount never wraps; the name ellipsizes.
class PersonRow extends ConsumerWidget {
  const PersonRow({
    super.key,
    required this.person,
    required this.isAllGroups,
    required this.groupNames,
    required this.onTap,
  });

  final PersonBalance person;

  /// The "Todos los grupos" tab: the detail names the groups.
  final bool isAllGroups;

  /// Group id → name.
  final Map<String, String> groupNames;
  final VoidCallback onTap;

  String _detail(String handle) {
    final String info;
    if (person.balance == 0) {
      final last = person.lastActivityAt;
      info = last == null
          ? BalancesStrings.noMovements
          : BalancesStrings.lastActivity(BalancesDates.short(last));
    } else if (isAllGroups) {
      final ids = person.groupIds;
      info = ids.length == 1
          ? groupNames[ids.single] ?? BalancesStrings.groupCount(1)
          : BalancesStrings.groupCount(ids.length);
    } else if (person.newCount > 0) {
      info = BalancesStrings.newCount(person.newCount);
    } else {
      info = BalancesStrings.pendingCount(person.pendingCount);
    }
    return handle.isEmpty ? info : '$handle · $info';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final profile = ref.watch(userProfileProvider(person.uid)).value;
    final name = PersonNames.full(profile);
    final nickname = PersonNames.nickname(profile);
    final handle = nickname.isEmpty ? '' : BalancesStrings.handle(nickname);
    final balance = person.balance;
    final (amountColor, caption) = balance > 0
        ? (tokens.positive, BalancesStrings.owesYou)
        : balance < 0
        ? (tokens.negative, BalancesStrings.youOweThem)
        : (tokens.textSecondary, BalancesStrings.settled);

    return Semantics(
      button: true,
      label: BalancesStrings.rowLabel(
        name.isEmpty ? handle : name,
        balance,
        person.pendingCount,
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: BalancesMetrics.rowMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BalancesMetrics.rowPaddingH,
              vertical: BalancesMetrics.rowPaddingV,
            ),
            child: Row(
              children: [
                PersonAvatar(
                  profile: profile,
                  size: BalancesMetrics.avatar,
                  heroTag: personAvatarTag(person.uid),
                ),
                const SizedBox(width: BalancesMetrics.rowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.rowTitle,
                      ),
                      Text(
                        _detail(handle),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.rowDetail,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: BalancesMetrics.rowGap),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      MoneyFormat.format(balance),
                      maxLines: 1,
                      softWrap: false,
                      style: styles.rowAmount.copyWith(
                        color: balance == 0
                            ? tokens.textSecondary
                            : amountColor,
                      ),
                    ),
                    Text(caption, maxLines: 1, style: styles.caption),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
