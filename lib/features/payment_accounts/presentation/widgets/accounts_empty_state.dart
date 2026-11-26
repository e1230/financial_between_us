import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import 'payment_account_logo.dart';

/// "Aún no tienes cuentas": the dashed logo over a tilted tile, a title
/// and a short explanation (the "Agregar cuenta" button is placed by the
/// screen, at the bottom).
class AccountsEmptyState extends StatelessWidget {
  const AccountsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: SizedBox.square(
            dimension: PaymentAccountsMetrics.emptyArtSize,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: PaymentAccountsMetrics.emptyArtBackTop,
                  child: Transform.rotate(
                    angle: PaymentAccountsMetrics.emptyArtTilt * math.pi / 180,
                    child: Container(
                      width: PaymentAccountsMetrics.logoLarge,
                      height: PaymentAccountsMetrics.logoLarge,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(
                          PaymentAccountsMetrics.logoLargeRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: PaymentAccountsMetrics.emptyArtLogoLeft,
                  top: PaymentAccountsMetrics.emptyArtLogoTop,
                  child: PaymentAccountLogo(
                    type: null,
                    size: PaymentAccountLogoSize.large,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PaymentAccountsMetrics.emptyTitleGap),
        Semantics(
          header: true,
          child: Text(
            PaymentAccountsStrings.emptyTitle,
            style: styles.emptyTitle,
          ),
        ),
        SizedBox(height: tokens.space1),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: PaymentAccountsMetrics.emptyTextMaxWidth,
          ),
          child: Text(
            PaymentAccountsStrings.emptyText,
            style: styles.emptyText,
          ),
        ),
      ],
    );
  }
}
