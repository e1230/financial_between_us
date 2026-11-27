import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../auth/data/auth_providers.dart';
import '../../../groups/data/groups_providers.dart';
import '../../../groups/domain/group.dart';
import '../../../profile/data/profile_providers.dart';
import '../../../profile/domain/user_profile.dart';
import '../../data/balances_providers.dart';
import '../../domain/balances_overview.dart';
import '../../domain/balances_scope.dart';
import '../../domain/pair_ledger.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../sheets/balances_sheet.dart';
import '../widgets/balances_card.dart';
import '../widgets/balances_skeleton.dart';
import '../widgets/person_avatar.dart';
import 'quick_movement_kind.dart';

/// The person chosen in [showPersonPicker], with what is needed to open the
/// payment or debt sheet.
final class PickedPerson {
  const PickedPerson({
    required this.me,
    required this.group,
    required this.profile,
    required this.ledger,
  });

  final String me;
  final Group group;
  final UserProfile? profile;

  /// The user's ledger with them in [group].
  final PairLedger ledger;

  String get uid => ledger.other;
}

/// Lets the user pick, in the active group, who paid them ([kind] income:
/// people who owe them), whom they paid (payment: people they owe) or whom
/// the debt is with (debt: every active member). `null` when dismissed.
Future<PickedPerson?> showPersonPicker(
  BuildContext context, {
  required QuickMovementKind kind,
}) => showBalancesSheet<PickedPerson>(
  context: context,
  builder: (_) => _PersonPicker(kind: kind),
);

class _PersonPicker extends ConsumerWidget {
  const _PersonPicker({required this.kind});

  final QuickMovementKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = BalancesTextStyles.of(context);
    final me = ref.watch(authStateChangesProvider).value?.uid ?? '';
    final group = ref.watch(activeGroupProvider).value;
    final title = switch (kind) {
      QuickMovementKind.income => BalancesStrings.whoPaidYou,
      QuickMovementKind.payment => BalancesStrings.whoDidYouPay,
      QuickMovementKind.debt => BalancesStrings.whoIsTheDebtWith,
    };
    if (group == null) {
      return BalancesSheetFrame(title: title, children: const []);
    }

    final inputsAsync = ref.watch(
      scopeLedgerInputsProvider(BalancesScope.group(group.id)),
    );
    final inputs = inputsAsync.value;
    final Widget content;
    if (inputs != null) {
      final movements = [for (final i in inputs) ...i.movements];
      final overview = BalancesOverview.compute(me: me, groups: inputs);
      final balances = {
        for (final p in [
          ...overview.owedToMe,
          ...overview.iOwe,
          ...overview.settled,
        ])
          p.uid: p.balance,
      };
      final uids = switch (kind) {
        QuickMovementKind.income => [for (final p in overview.owedToMe) p.uid],
        QuickMovementKind.payment => [for (final p in overview.iOwe) p.uid],
        QuickMovementKind.debt => [
          for (final uid in group.memberUids)
            if (uid != me) uid,
        ],
      };
      content = uids.isEmpty
          ? Text(switch (kind) {
              QuickMovementKind.income => BalancesStrings.nobodyOwesYou(
                group.name,
              ),
              QuickMovementKind.payment => BalancesStrings.youOweNobody(
                group.name,
              ),
              QuickMovementKind.debt => BalancesStrings.noOtherMembers(
                group.name,
              ),
            }, style: styles.body)
          : BalancesCard(
              children: [
                for (final uid in uids)
                  _PersonOption(
                    uid: uid,
                    balance: balances[uid] ?? 0,
                    onPick: (profile) => Navigator.of(context).pop(
                      PickedPerson(
                        me: me,
                        group: group,
                        profile: profile,
                        ledger: PairLedger.compute(
                          me: me,
                          other: uid,
                          movements: movements,
                        ),
                      ),
                    ),
                  ),
              ],
            );
    } else if (inputsAsync.hasError) {
      content = Text(BalancesStrings.loadError, style: styles.body);
    } else {
      content = const BalancesSkeleton();
    }

    return BalancesSheetFrame(
      title: title,
      subtitle: BalancesStrings.inGroup(group.name),
      children: [content],
    );
  }
}

/// A person of the picker: avatar, name and "@usuario · te debe $ X".
class _PersonOption extends ConsumerWidget {
  const _PersonOption({
    required this.uid,
    required this.balance,
    required this.onPick,
  });

  final String uid;
  final int balance;
  final ValueChanged<UserProfile?> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = BalancesTextStyles.of(context);
    final profile = ref.watch(userProfileProvider(uid)).value;
    final nickname = PersonNames.nickname(profile);
    final detail = [
      if (nickname.isNotEmpty) BalancesStrings.handle(nickname),
      if (balance > 0) BalancesStrings.owesYouAmount(balance),
      if (balance < 0) BalancesStrings.youOweAmount(-balance),
    ].join(' · ');
    return MergeSemantics(
      child: InkWell(
        onTap: () => onPick(profile),
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
                PersonAvatar(profile: profile, size: BalancesMetrics.avatar),
                const SizedBox(width: BalancesMetrics.rowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PersonNames.full(profile),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.rowTitle,
                      ),
                      if (detail.isNotEmpty)
                        Text(
                          detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.rowDetail,
                        ),
                    ],
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
