import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../domain/pair_ledger.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/balances_card.dart';
import '../widgets/movement_icon.dart';
import '../widgets/type_chip.dart';

/// "PENDIENTES": the items still owed, oldest first, or "No tienen nada
/// pendiente." Items that get settled leave with a collapse (250 ms).
class PendingCard extends StatelessWidget {
  const PendingCard({
    super.key,
    required this.pendings,
    required this.me,
    required this.otherFirst,
    required this.onOpen,
  });

  final List<PendingItem> pendings;
  final String me;
  final String otherFirst;
  final ValueChanged<PendingItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: reduceMotion
          ? BalancesMetrics.reducedFade
          : BalancesMetrics.settledResize,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: pendings.isEmpty
          ? Container(
              width: double.infinity,
              padding: EdgeInsets.all(tokens.space2),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radiusCard),
              ),
              child: Text(BalancesStrings.noPending, style: styles.body),
            )
          : BalancesCard(
              children: [
                for (final item in pendings)
                  _PendingRow(
                    key: ValueKey(item.id),
                    item: item,
                    me: me,
                    otherFirst: otherFirst,
                    onTap: () => onOpen(item),
                  ),
              ],
            ),
    );
  }
}

class _PendingRow extends StatelessWidget {
  const _PendingRow({
    super.key,
    required this.item,
    required this.me,
    required this.otherFirst,
    required this.onTap,
  });

  final PendingItem item;
  final String me;
  final String otherFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final owedToMe = item.creditorUid == me;
    final color = owedToMe ? tokens.positive : tokens.negative;
    final (icon, chip, kindLabel) = switch (item.kind) {
      PendingKind.event => (
        MovementIconKind.event,
        TypeChipKind.event,
        BalancesStrings.event,
      ),
      PendingKind.direct => (
        MovementIconKind.direct,
        TypeChipKind.direct,
        BalancesStrings.direct,
      ),
      PendingKind.credit => (
        MovementIconKind.credit,
        TypeChipKind.credit,
        BalancesStrings.credit,
      ),
    };
    final title = item.kind == PendingKind.credit
        ? BalancesStrings.credit
        : item.title;
    final date = BalancesDates.short(item.date);
    final String? caption = item.isReduced
        ? BalancesStrings.ofTotal(item.original)
        : item.kind == PendingKind.event
        ? (item.creditorUid == me
              ? BalancesStrings.youPaidBill
              : BalancesStrings.paidBill(otherFirst))
        : null;

    return Semantics(
      button: true,
      label: BalancesStrings.pendingLabel(
        title: title,
        kind: kindLabel.toLowerCase(),
        date: BalancesDates.spoken(item.date),
        remaining: item.remaining,
        original: item.original,
      ),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: BalancesMetrics.pendingRowMinHeight,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BalancesMetrics.rowPaddingH,
                  vertical: BalancesMetrics.rowPaddingV,
                ),
                child: Row(
                  children: [
                    MovementIcon(icon),
                    const SizedBox(width: BalancesMetrics.rowGap),
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
                          const SizedBox(
                            height: BalancesMetrics.chipPaddingV * 2,
                          ),
                          // Wraps under the chip with large text.
                          Wrap(
                            spacing: tokens.space1,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TypeChip(chip),
                              Text(
                                switch ((
                                  item.isPartiallyPaid,
                                  item.isPartiallyOffset,
                                )) {
                                  (true, true) =>
                                    '$date · ${BalancesStrings.paidAndOffset}',
                                  (true, false) =>
                                    '$date · ${BalancesStrings.partiallyPaid}',
                                  (false, true) =>
                                    '$date · ${BalancesStrings.partiallyOffset}',
                                  (false, false) => date,
                                },
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.rowDetail,
                              ),
                            ],
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
                          style: styles.rowAmount.copyWith(color: color),
                        ),
                        if (caption != null)
                          Text(
                            caption,
                            maxLines: 1,
                            softWrap: false,
                            style: styles.caption,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.isReduced)
                Positioned(
                  left: BalancesMetrics.dividerInset,
                  right: BalancesMetrics.rowPaddingH,
                  bottom: BalancesMetrics.rowPaddingV / 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                    child: LinearProgressIndicator(
                      value: item.paidFraction,
                      minHeight: BalancesMetrics.progressHeight,
                      backgroundColor: tokens.border,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
