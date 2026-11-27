import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_toast.dart';
import '../../../payment_accounts/domain/payment_account.dart';
import '../../../payment_accounts/domain/payment_account_rules.dart';
import '../../../payment_accounts/presentation/widgets/payment_account_logo.dart';
import '../../domain/ledger_movement.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';

/// An account a payment can go to: one of the payment accounts, or cash.
final class AccountOption {
  const AccountOption({
    required this.key,
    required this.snapshot,
    this.account,
  });

  /// An option per account, plus "Efectivo" if none of them is cash.
  static List<AccountOption> listOf(List<PaymentAccount> accounts) => [
    for (final a in accounts)
      AccountOption(
        key: a.id,
        account: a,
        snapshot: AccountSnapshot(
          type: a.type,
          name: a.name,
          reference: a.reference,
        ),
      ),
    if (!accounts.any((a) => a.type == PaymentAccountType.cash)) cash,
  ];

  static const AccountOption cash = AccountOption(
    key: 'cash',
    snapshot: AccountSnapshot(
      type: PaymentAccountType.cash,
      name: BalancesStrings.cash,
    ),
  );

  final String key;
  final AccountSnapshot snapshot;

  /// `null` for [cash].
  final PaymentAccount? account;
}

/// "¿A CUÁL DE TUS CUENTAS TE PAGÓ?": a horizontal row of 48 dp chips with
/// the logo and name of the user's accounts; the selected one has a green
/// border.
class AccountChips extends StatelessWidget {
  const AccountChips({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onSelect,
  });

  final List<AccountOption> options;
  final String? selectedKey;
  final ValueChanged<AccountOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final option in options) ...[
            if (option != options.first) SizedBox(width: tokens.space1),
            Semantics(
              button: true,
              selected: option.key == selectedKey,
              inMutuallyExclusiveGroup: true,
              child: InkWell(
                onTap: () => onSelect(option),
                borderRadius: BorderRadius.circular(tokens.radiusInput),
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? BalancesMetrics.reducedFade
                      : BalancesMetrics.checkboxFade,
                  height: BalancesMetrics.accountChipHeight,
                  padding: EdgeInsets.symmetric(horizontal: tokens.space1),
                  decoration: BoxDecoration(
                    color: tokens.surfaceVariant,
                    borderRadius: BorderRadius.circular(tokens.radiusInput),
                    border: Border.all(
                      color: option.key == selectedKey
                          ? tokens.accent
                          : tokens.surfaceVariant,
                      width: BalancesMetrics.focusBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PaymentAccountLogo(type: option.snapshot.type),
                      const SizedBox(width: BalancesMetrics.rowGap),
                      Text(option.snapshot.name, style: styles.rowTitle),
                      SizedBox(width: tokens.space1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "¿A CUÁL DE SUS CUENTAS LE PAGASTE?": 56 dp radio rows with the logo,
/// name and reference of the other person's accounts (each with a copy
/// button) and "Efectivo · En persona" last.
class AccountRadioList extends StatelessWidget {
  const AccountRadioList({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onSelect,
  });

  final List<AccountOption> options;
  final String? selectedKey;
  final ValueChanged<AccountOption> onSelect;

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
        position: FbuToastPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
      ),
      child: Column(
        children: [
          for (final option in options)
            _radioRow(context, tokens, styles, option),
        ],
      ),
    );
  }

  Widget _radioRow(
    BuildContext context,
    AppTokens tokens,
    BalancesTextStyles styles,
    AccountOption option,
  ) {
    final selected = option.key == selectedKey;
    final account = option.account;
    final reference = account == null
        ? BalancesStrings.inPerson
        : PaymentAccountRules.displayReference(account);
    return Semantics(
      selected: selected,
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: () => onSelect(option),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: BalancesMetrics.accountRadioHeight,
          ),
          child: Padding(
            padding: EdgeInsets.only(left: tokens.space2),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: BalancesMetrics.checkboxFade,
                  width: BalancesMetrics.radioSize,
                  height: BalancesMetrics.radioSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? tokens.accent : tokens.outlineMuted,
                      width: BalancesMetrics.focusBorder,
                    ),
                  ),
                  child: AnimatedOpacity(
                    duration: BalancesMetrics.checkboxFade,
                    opacity: selected ? 1 : 0,
                    child: Container(
                      width: BalancesMetrics.radioDot,
                      height: BalancesMetrics.radioDot,
                      decoration: BoxDecoration(
                        color: tokens.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: BalancesMetrics.rowGap),
                PaymentAccountLogo(type: option.snapshot.type),
                const SizedBox(width: BalancesMetrics.rowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.snapshot.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.rowTitle,
                      ),
                      Text(
                        reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.rowDetail,
                      ),
                    ],
                  ),
                ),
                if (account != null && account.hasReference)
                  IconButton(
                    tooltip: BalancesStrings.copyAccount(account.name),
                    constraints: const BoxConstraints.tightFor(
                      width: BalancesMetrics.touchTarget,
                      height: BalancesMetrics.touchTarget,
                    ),
                    iconSize: BalancesMetrics.attachIcon,
                    color: tokens.textSecondary,
                    onPressed: () => _copy(context, account),
                    icon: const Icon(Icons.copy_outlined),
                  )
                else
                  SizedBox(width: tokens.space2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
