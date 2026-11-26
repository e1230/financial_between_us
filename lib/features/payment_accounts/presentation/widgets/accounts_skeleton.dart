import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';

/// Three placeholder rows in the accounts card while they load.
class AccountsSkeleton extends StatelessWidget {
  const AccountsSkeleton({
    super.key,
    this.label = PaymentAccountsStrings.loading,
  });

  /// Announced by screen readers.
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget bar(double width) => Container(
      width: width,
      height: PaymentAccountsMetrics.skeletonLine,
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
    );
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(tokens.radiusCard),
          ),
          child: Column(
            children: [
              for (var i = 0; i < PaymentAccountsMetrics.skeletonRows; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: PaymentAccountsMetrics.dividerInset,
                    color: tokens.border,
                  ),
                Container(
                  height: PaymentAccountsMetrics.rowMinHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PaymentAccountsMetrics.rowPaddingH,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bar(
                                constraints.maxWidth *
                                    PaymentAccountsMetrics.skeletonNameWidth,
                              ),
                              SizedBox(height: tokens.space1),
                              bar(
                                constraints.maxWidth *
                                    PaymentAccountsMetrics
                                        .skeletonReferenceWidth,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: PaymentAccountsMetrics.rowGap),
                      Container(
                        width: PaymentAccountsMetrics.logoSmall,
                        height: PaymentAccountsMetrics.logoSmall,
                        decoration: BoxDecoration(
                          color: tokens.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            PaymentAccountsMetrics.logoSmallRadius,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
