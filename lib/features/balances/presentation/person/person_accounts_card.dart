import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_toast.dart';
import '../../../payment_accounts/data/payment_accounts_providers.dart';
import '../../../payment_accounts/domain/payment_account.dart';
import '../../../payment_accounts/domain/payment_account_rules.dart';
import '../../../payment_accounts/presentation/widgets/payment_account_logo.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/balances_card.dart';
import '../widgets/section_label.dart';

/// "CUENTAS DE {NOMBRE}": the accounts of the person the user owes, each
/// with a 48 dp copy button. Hidden while loading, on error or when they
/// have none.
class PersonAccountsCard extends ConsumerWidget {
  const PersonAccountsCard({
    super.key,
    required this.uid,
    required this.firstName,
  });

  final String uid;
  final String firstName;

  static Future<void> _copy(
    BuildContext context,
    PaymentAccount account,
  ) async {
    await Clipboard.setData(ClipboardData(text: account.reference));
    await HapticFeedback.lightImpact();
    if (context.mounted) {
      FbuToast.show(
        context,
        BalancesStrings.copied(PaymentAccountRules.displayReference(account)),
        position: FbuToastPosition.aboveActions,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final accounts = [
      for (final a
          in ref.watch(paymentAccountsOfProvider(uid)).value ??
              const <PaymentAccount>[])
        if (a.hasReference) a,
    ];
    if (accounts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: BalancesMetrics.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(BalancesStrings.accountsOf(firstName)),
          BalancesCard(
            dividerInset: BalancesMetrics.rowPaddingH * 2 + tokens.space4,
            children: [
              for (final account in accounts)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: BalancesMetrics.accountRadioHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: BalancesMetrics.rowPaddingH,
                    ),
                    child: Row(
                      children: [
                        PaymentAccountLogo(type: account.type),
                        const SizedBox(width: BalancesMetrics.rowGap),
                        Expanded(
                          child: MergeSemantics(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.rowTitle,
                                ),
                                Text(
                                  PaymentAccountRules.displayReference(account),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.rowDetail,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: BalancesStrings.copyAccount(account.name),
                          constraints: const BoxConstraints.tightFor(
                            width: BalancesMetrics.accountCopyButton,
                            height: BalancesMetrics.accountCopyButton,
                          ),
                          iconSize: BalancesMetrics.attachIcon,
                          color: tokens.textSecondary,
                          onPressed: () => _copy(context, account),
                          icon: const Icon(Icons.copy_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
