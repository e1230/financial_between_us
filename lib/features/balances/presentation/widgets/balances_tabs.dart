import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/balances_scope.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';

/// "{grupo activo}" | "Todos los grupos": a 44 dp pill whose white
/// indicator slides (250 ms, fast-out-slow-in) to the selected half. The
/// group half is disabled while there is no active group.
class BalancesTabs extends StatelessWidget {
  const BalancesTabs({
    super.key,
    required this.groupName,
    required this.selected,
    required this.onSelect,
  });

  /// Name of the active group; `null` without one.
  final String? groupName;
  final BalancesTab selected;
  final ValueChanged<BalancesTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isGroup = selected == BalancesTab.group;

    Widget half(BalancesTab tab, String label, {bool enabled = true}) {
      final isSelected = tab == selected;
      return Expanded(
        child: Semantics(
          button: true,
          selected: isSelected,
          enabled: enabled,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled && !isSelected ? () => onSelect(tab) : null,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.space1),
                child: AnimatedDefaultTextStyle(
                  duration: reduceMotion
                      ? BalancesMetrics.reducedFade
                      : BalancesMetrics.tabSlide,
                  style: styles.tab.copyWith(
                    color: isSelected
                        ? tokens.background
                        : enabled
                        ? tokens.textSecondary
                        : tokens.textDisabled,
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: BalancesMetrics.tabsHeight,
      padding: const EdgeInsets.all(BalancesMetrics.tabsPadding),
      decoration: ShapeDecoration(
        color: tokens.surface,
        shape: const StadiumBorder(),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: reduceMotion ? Duration.zero : BalancesMetrics.tabSlide,
            curve: Curves.fastOutSlowIn,
            alignment: isGroup ? Alignment.centerLeft : Alignment.centerRight,
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
              half(
                BalancesTab.group,
                groupName ?? BalancesStrings.title,
                enabled: groupName != null,
              ),
              half(BalancesTab.all, BalancesStrings.allGroups),
            ],
          ),
        ],
      ),
    );
  }
}
