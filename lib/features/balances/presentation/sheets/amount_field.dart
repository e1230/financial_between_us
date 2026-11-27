import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';

/// Formats the typed digits as pesos while typing (`$ 72.000`), keeping the
/// cursor at the end. At most [maxDigits] digits.
class PesosInputFormatter extends TextInputFormatter {
  const PesosInputFormatter({this.maxDigits = 9});

  final int maxDigits;

  /// Whole pesos of [text], or `null` when it has no digits.
  static int? parse(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  /// [pesos] as the field shows it.
  static String format(int? pesos) =>
      pesos == null ? '' : MoneyFormat.format(pesos);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }
    final value = digits.isEmpty ? null : int.parse(digits);
    final text = format(value);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// "Monto": a 72 dp filled field with the amount in Inter 28/34 w600
/// (tabular), a number keyboard and a 1.5 dp green border while focused.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<int?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final error = errorText;
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        final borderColor = error != null
            ? tokens.negative
            : focused
            ? tokens.accent
            : Colors.transparent;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(
                minHeight: BalancesMetrics.amountFieldHeight,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space2,
                vertical: tokens.space1,
              ),
              decoration: BoxDecoration(
                color: tokens.surfaceVariant,
                borderRadius: BorderRadius.circular(tokens.radiusInput),
                border: Border.all(
                  color: borderColor,
                  width: BalancesMetrics.focusBorder,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    BalancesStrings.amount,
                    style: styles.caption.copyWith(
                      color: focused ? tokens.accent : tokens.textSecondary,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: const [PesosInputFormatter()],
                    style: styles.amountInput,
                    cursorColor: tokens.accent,
                    onChanged: (text) =>
                        onChanged?.call(PesosInputFormatter.parse(text)),
                    decoration:
                        InputDecoration.collapsed(
                          hintText: MoneyFormat.format(0),
                          hintStyle: styles.amountInput.copyWith(
                            color: tokens.textDisabled,
                          ),
                        ).copyWith(
                          semanticCounterText: '',
                          // The label above already names the field.
                          labelText: null,
                        ),
                  ),
                ],
              ),
            ),
            if (error != null) ...[
              SizedBox(height: tokens.space1),
              Semantics(
                liveRegion: true,
                child: Text(
                  error,
                  style: styles.body.copyWith(color: tokens.negative),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
