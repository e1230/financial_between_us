import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/counting_amount.dart';

/// The balance with a person: "Te debe" (green, with "Recordarle"), "Le
/// debes" (red) or "A paz y salvo" (a shield that pops in). The amount
/// counts to its new value (500 ms) and the states cross-fade (250 ms).
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.pendingCount,
    required this.oldestPendingAt,
    required this.lastActivityAt,
    required this.onRemind,
  });

  /// Positive "te debe", negative "le debes", zero even.
  final int balance;
  final int pendingCount;
  final DateTime? oldestPendingAt;
  final DateTime? lastActivityAt;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final settled = balance == 0;

    final Widget content;
    if (settled) {
      final last = lastActivityAt;
      content = Row(
        key: const ValueKey('settled'),
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(
              begin: reduceMotion ? 1 : BalancesMetrics.shieldStartScale,
              end: 1,
            ),
            duration: BalancesMetrics.shieldPop,
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: BalancesMetrics.shieldCircle,
              height: BalancesMetrics.shieldCircle,
              decoration: BoxDecoration(
                color: tokens.positive.withValues(
                  alpha: BalancesMetrics.semanticTint,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: BalancesMetrics.shieldCircleIcon,
                color: tokens.positive,
              ),
            ),
          ),
          SizedBox(width: tokens.space2),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(BalancesStrings.settledTitle, style: styles.personName),
                  Text(
                    last == null
                        ? BalancesStrings.noMovementYet
                        : BalancesStrings.lastMovement(
                            BalancesDates.relative(last),
                          ),
                    style: styles.label,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      final owesMe = balance > 0;
      final oldest = oldestPendingAt;
      content = Row(
        key: const ValueKey('balance'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owesMe
                        ? BalancesStrings.owesYouLabel
                        : BalancesStrings.youOweLabel,
                    style: styles.label,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: CountingAmount(
                      value: balance.abs(),
                      format: MoneyFormat.format,
                      firstDuration: Duration.zero,
                      duration: BalancesMetrics.balanceRecount,
                      style: styles.balanceAmount.copyWith(
                        color: owesMe ? tokens.positive : tokens.negative,
                      ),
                    ),
                  ),
                  if (oldest != null)
                    Text(
                      BalancesStrings.pendingSince(
                        pendingCount,
                        BalancesDates.short(oldest),
                      ),
                      style: styles.label,
                    ),
                ],
              ),
            ),
          ),
          if (owesMe) ...[
            SizedBox(width: tokens.space1),
            _RemindButton(onPressed: onRemind),
          ],
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(BalancesMetrics.summaryPadding),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radiusPanel),
      ),
      child: AnimatedSwitcher(
        duration: reduceMotion
            ? BalancesMetrics.reducedFade
            : BalancesMetrics.settledSwap,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: content,
      ),
    );
  }
}

/// "Recordarle": a 36 dp pill (48 dp to touch) with a bell.
class _RemindButton extends StatelessWidget {
  const _RemindButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: BalancesMetrics.touchTarget,
          ),
          child: Center(
            widthFactor: 1,
            child: Container(
              height: BalancesMetrics.remindHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: BalancesMetrics.remindPaddingH,
              ),
              decoration: ShapeDecoration(
                color: tokens.textPrimary.withValues(
                  alpha: BalancesMetrics.neutralTint,
                ),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: BalancesMetrics.remindIcon,
                    color: tokens.textPrimary,
                  ),
                  SizedBox(width: tokens.space1),
                  Text(BalancesStrings.remind, style: styles.tab),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
