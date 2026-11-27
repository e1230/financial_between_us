import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';

/// Fixed bar at the bottom of the person detail: "Registrar deuda" and
/// "Registrar pago" (only "Registrar deuda", green and full width, when
/// even), over a fade from transparent to the background in 24 dp.
class PersonActionBar extends StatelessWidget {
  const PersonActionBar({
    super.key,
    required this.isSettled,
    required this.onDebt,
    required this.onPayment,
  });

  final bool isSettled;
  final VoidCallback? onDebt;
  final VoidCallback? onPayment;

  /// Height of the bar without the gesture bar inset.
  static const double height =
      BalancesMetrics.actionBarTop +
      FbuPrimaryButton.height +
      BalancesMetrics.actionBarBottom;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final padding = MediaQuery.paddingOf(context);
    const fade = BalancesMetrics.actionBarFade / height;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tokens.background.withValues(alpha: 0), tokens.background],
          stops: const [0, fade],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.space2,
          BalancesMetrics.actionBarTop,
          tokens.space2,
          BalancesMetrics.actionBarBottom + padding.bottom,
        ),
        child: isSettled
            ? FbuPrimaryButton(
                onPressed: onDebt,
                child: const Text(BalancesStrings.registerDebt),
              )
            : Row(
                children: [
                  Expanded(
                    child: FbuSecondaryButton(
                      onPressed: onDebt,
                      child: const Text(
                        BalancesStrings.registerDebt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: BalancesMetrics.actionBarGap),
                  Expanded(
                    child: FbuPrimaryButton(
                      onPressed: onPayment,
                      child: const Text(
                        BalancesStrings.registerPayment,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
