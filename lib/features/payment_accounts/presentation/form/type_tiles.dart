import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/payment_account.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import '../widgets/payment_account_logo.dart';

/// Row of five tiles to pick the account type (a radio group): Bre-B,
/// Nequi, Daviplata, Efectivo and Otro. The chosen one gets a green border
/// and a lighter fill (150 ms).
class TypeTiles extends StatelessWidget {
  const TypeTiles({super.key, required this.selected, required this.onSelect});

  final PaymentAccountType? selected;
  final ValueChanged<PaymentAccountType> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: PaymentAccountsMetrics.tileGap,
      children: [
        for (final type in PaymentAccountType.formOrder)
          Expanded(
            child: Builder(
              builder: (context) {
                final isSelected = type == selected;
                final radius = BorderRadius.circular(tokens.radiusCard);
                return Semantics(
                  inMutuallyExclusiveGroup: true,
                  checked: isSelected,
                  button: true,
                  label: type.label,
                  excludeSemantics: true,
                  onTap: () => onSelect(type),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelect(type),
                      borderRadius: radius,
                      child: AnimatedContainer(
                        duration: reduceMotion
                            ? Duration.zero
                            : tokens.motionFast,
                        constraints: const BoxConstraints(
                          minHeight: PaymentAccountsMetrics.tileHeight,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: PaymentAccountsMetrics.tilePaddingV,
                          horizontal: PaymentAccountsMetrics.tilePaddingH,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? tokens.surfaceVariant
                              : tokens.surface,
                          borderRadius: radius,
                          border: Border.all(
                            width: PaymentAccountsMetrics.tileBorder,
                            color: isSelected
                                ? tokens.accent
                                : tokens.accent.withValues(alpha: 0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PaymentAccountLogo(type: type),
                            const SizedBox(
                              height: PaymentAccountsMetrics.tileInnerGap,
                            ),
                            Text(
                              type.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: isSelected
                                  ? styles.tileLabel.copyWith(
                                      color: tokens.textPrimary,
                                    )
                                  : styles.tileLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
