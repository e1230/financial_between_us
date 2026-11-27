import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../domain/pair_ledger.dart';
import '../../domain/payment_allocation.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';

/// "SE APLICA A": a 48 dp row per pending item (oldest first) with a
/// checkbox, its title and "Tipo · fecha" ("· saldo" after a partial
/// payment) and what it still owes, or "abona $ X" when the payment only
/// covers part of it. Checkboxes follow the allocation and fade (120 ms).
class AppliesToBox extends StatelessWidget {
  const AppliesToBox({
    super.key,
    required this.pendings,
    required this.allocations,
    required this.onToggle,
  });

  final List<PendingItem> pendings;
  final List<Allocation> allocations;
  final ValueChanged<PendingItem> onToggle;

  static String kindLabel(PendingKind kind) => switch (kind) {
    PendingKind.event => BalancesStrings.event,
    PendingKind.direct => BalancesStrings.direct,
    PendingKind.credit => BalancesStrings.credit,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final byId = {for (final a in allocations) a.item.id: a};
    final fade = MediaQuery.disableAnimationsOf(context)
        ? BalancesMetrics.reducedFade
        : BalancesMetrics.checkboxFade;

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.symmetric(vertical: tokens.space1),
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
      ),
      child: Column(
        children: [
          for (final item in pendings)
            Builder(
              builder: (context) {
                final allocation = byId[item.id];
                final checked = allocation != null;
                final title = item.kind == PendingKind.credit
                    ? BalancesStrings.credit
                    : item.title;
                final sub = [
                  kindLabel(item.kind),
                  BalancesDates.short(item.date),
                  if (item.isPartiallyPaid) BalancesStrings.balanceSuffix,
                ].join(' · ');
                return Semantics(
                  checked: checked,
                  label: '$title, $sub, ${MoneyFormat.format(item.remaining)}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onToggle(item),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: BalancesMetrics.appliesRowHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space2,
                          vertical: BalancesMetrics.sectionLabelBottomGap / 2,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: fade,
                              width: BalancesMetrics.checkbox,
                              height: BalancesMetrics.checkbox,
                              decoration: BoxDecoration(
                                color: checked
                                    ? tokens.accent
                                    : tokens.background,
                                borderRadius: BorderRadius.circular(
                                  BalancesMetrics.checkboxRadius,
                                ),
                                border: Border.all(
                                  color: checked
                                      ? tokens.accent
                                      : tokens.outlineMuted,
                                  width: BalancesMetrics.focusBorder,
                                ),
                              ),
                              child: AnimatedOpacity(
                                duration: fade,
                                opacity: checked ? 1 : 0,
                                child: Icon(
                                  Icons.check,
                                  size: BalancesMetrics.checkIcon,
                                  color: tokens.onAccent,
                                ),
                              ),
                            ),
                            SizedBox(width: tokens.space2),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: styles.rowTitle,
                                  ),
                                  Text(
                                    sub,
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
                                  MoneyFormat.format(item.remaining),
                                  maxLines: 1,
                                  softWrap: false,
                                  style: styles.rowTitle.copyWith(
                                    color: checked
                                        ? tokens.textPrimary
                                        : tokens.textSecondary,
                                  ),
                                ),
                                if (allocation != null && allocation.isPartial)
                                  Text(
                                    BalancesStrings.appliesPartially(
                                      allocation.amount,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                    style: styles.caption.copyWith(
                                      color: tokens.positive,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
