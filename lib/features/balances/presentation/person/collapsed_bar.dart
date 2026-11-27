import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../../profile/domain/user_profile.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/person_avatar.dart';

/// Top bar once the detail scrolls past 120 dp: the avatar (32), the name
/// and the balance in its color, over the background. Fades in 150 ms.
class PersonCollapsedBar extends StatelessWidget {
  const PersonCollapsedBar({
    super.key,
    required this.visible,
    required this.profile,
    required this.balance,
  });

  final bool visible;
  final UserProfile? profile;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final amount = MoneyFormat.format(balance);
    final (text, color) = balance > 0
        ? ('${BalancesStrings.owesYouLabel} $amount', tokens.positive)
        : balance < 0
        ? ('${BalancesStrings.youOweLabel} $amount', tokens.negative)
        : (BalancesStrings.settledTitle, tokens.textSecondary);
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? BalancesMetrics.reducedFade
          : BalancesMetrics.headerCollapse,
      child: !visible
          ? const SizedBox.shrink()
          : Container(
              color: tokens.background,
              padding: EdgeInsets.only(
                top: padding.top + BalancesMetrics.headerTopGap,
                bottom: BalancesMetrics.headerTopGap,
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: BalancesMetrics.backSize + BalancesMetrics.backLeft,
                    height: BalancesMetrics.backSize,
                  ),
                  PersonAvatar(
                    profile: profile,
                    size: BalancesMetrics.collapsedAvatar,
                  ),
                  SizedBox(width: tokens.space1 + BalancesMetrics.backLeft),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PersonNames.full(profile),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.collapsedName,
                        ),
                        Text(
                          text,
                          maxLines: 1,
                          style: styles.caption.copyWith(color: color),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: tokens.space2),
                ],
              ),
            ),
    );
  }
}
