import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';

/// Back arrow on the left and the round "+" on the right of the list.
class AccountsTopBar extends StatelessWidget {
  const AccountsTopBar({super.key, required this.onAdd});

  /// `null` while the accounts load.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    const addSize = Size.square(PaymentAccountsMetrics.addButtonSize);
    return SizedBox(
      height: PaymentAccountsMetrics.touchTarget,
      child: Row(
        children: [
          const SizedBox(width: PaymentAccountsMetrics.backInset),
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: PaymentAccountsStrings.back,
            icon: Icon(
              Icons.arrow_back,
              size: PaymentAccountsMetrics.backIconSize,
              color: tokens.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onAdd,
            tooltip: PaymentAccountsStrings.add,
            style: IconButton.styleFrom(
              backgroundColor: tokens.surface,
              disabledBackgroundColor: tokens.surface,
              foregroundColor: tokens.textPrimary,
              disabledForegroundColor: tokens.textDisabled,
              side: BorderSide(color: tokens.border),
              fixedSize: addSize,
              minimumSize: addSize,
              padding: EdgeInsets.zero,
              // Keeps the 48 dp touch target around the 44 dp circle.
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            icon: const Icon(
              Icons.add,
              size: PaymentAccountsMetrics.addIconSize,
            ),
          ),
          // The 48 dp target overhangs the 44 dp circle by 2 dp.
          const SizedBox(
            width:
                PaymentAccountsMetrics.addButtonInset -
                (PaymentAccountsMetrics.touchTarget -
                        PaymentAccountsMetrics.addButtonSize) /
                    2,
          ),
        ],
      ),
    );
  }
}
