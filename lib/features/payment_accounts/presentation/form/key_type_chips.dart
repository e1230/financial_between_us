import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/payment_account.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';

/// "Tipo de llave" of a Bre-B account: Celular, Correo, Documento and
/// Alfanumérica as single-choice chips (a radio group). The chosen one is
/// light with dark text.
class KeyTypeChips extends StatelessWidget {
  const KeyTypeChips({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final BrebKeyType? selected;
  final ValueChanged<BrebKeyType> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            PaymentAccountsStrings.keyTypeLabel,
            style: styles.sectionLabel,
          ),
        ),
        const SizedBox(height: PaymentAccountsMetrics.keyLabelGap),
        Wrap(
          spacing: PaymentAccountsMetrics.keyChipGap,
          runSpacing: PaymentAccountsMetrics.keyChipGap,
          children: [
            for (final keyType in BrebKeyType.values)
              Builder(
                builder: (context) {
                  final isSelected = keyType == selected;
                  return Semantics(
                    inMutuallyExclusiveGroup: true,
                    checked: isSelected,
                    button: true,
                    label: keyType.label,
                    excludeSemantics: true,
                    onTap: () => onSelect(keyType),
                    child: Material(
                      color: Colors.transparent,
                      shape: const StadiumBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => onSelect(keyType),
                        child: AnimatedContainer(
                          duration: reduceMotion
                              ? Duration.zero
                              : tokens.motionFast,
                          // 36 dp tall with 13/18 text (taller when the
                          // text is scaled up).
                          padding: const EdgeInsets.symmetric(
                            horizontal: PaymentAccountsMetrics.keyChipPaddingH,
                            vertical:
                                (PaymentAccountsMetrics.keyChipHeight -
                                    PaymentAccountsMetrics.chipTextLineHeight) /
                                2,
                          ),
                          decoration: ShapeDecoration(
                            color: isSelected
                                ? tokens.textPrimary
                                : tokens.surfaceVariant,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            keyType.label,
                            style: styles.chip.copyWith(
                              color: isSelected
                                  ? tokens.background
                                  : tokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
