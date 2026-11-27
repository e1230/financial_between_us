import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';

/// "{Nombre} me debe" | "Yo le debo": a 44 dp pill on the background color
/// whose white half marks the direction.
class DirectionToggle extends StatelessWidget {
  const DirectionToggle({
    super.key,
    required this.theyOweMeLabel,
    required this.theyOweMe,
    required this.onChanged,
  });

  final String theyOweMeLabel;
  final bool theyOweMe;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget half(bool value, String label) {
      final selected = value == theyOweMe;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          inMutuallyExclusiveGroup: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onChanged == null ? null : () => onChanged!(value),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.space1),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.tab.copyWith(
                    color: selected ? tokens.background : tokens.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: BalancesMetrics.toggleHeight + BalancesMetrics.tabsPadding,
      padding: const EdgeInsets.all(BalancesMetrics.tabsPadding),
      decoration: ShapeDecoration(
        color: tokens.background,
        shape: const StadiumBorder(),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: reduceMotion ? Duration.zero : BalancesMetrics.tabSlide,
            curve: Curves.fastOutSlowIn,
            alignment: theyOweMe ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: tokens.textPrimary,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
          ),
          Row(
            children: [
              half(true, theyOweMeLabel),
              half(false, BalancesStrings.iOweThem),
            ],
          ),
        ],
      ),
    );
  }
}
