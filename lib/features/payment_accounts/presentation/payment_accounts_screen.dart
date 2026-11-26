import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/fbu_primary_button.dart';
import '../../../core/widgets/fbu_secondary_button.dart';
import '../../../core/widgets/fbu_toast.dart';
import '../data/payment_accounts_providers.dart';
import '../domain/payment_account.dart';
import '../domain/payment_account_rules.dart';
import 'form/payment_account_form_screen.dart';
import 'payment_accounts_metrics.dart';
import 'payment_accounts_strings.dart';
import 'payment_accounts_text_styles.dart';
import 'sheet/payment_account_sheet.dart';
import 'widgets/accounts_card.dart';
import 'widgets/accounts_empty_state.dart';
import 'widgets/accounts_skeleton.dart';
import 'widgets/accounts_top_bar.dart';

/// "Cuentas de pago": where the user receives payments (Nequi, Daviplata,
/// Bre-B keys, cash…), to share them with friends. Opened from the card
/// button of the Home header and from "Cuentas" in the avatar menu.
///
/// The accounts belong to the user, not to a group.
class PaymentAccountsScreen extends ConsumerWidget {
  const PaymentAccountsScreen({super.key});

  static Future<void> _add(BuildContext context, int count) async {
    if (count >= PaymentAccountRules.maxAccounts) {
      FbuToast.show(context, PaymentAccountsStrings.limitReached);
      return;
    }
    final result = await context.push<AccountFormResult>(AppRoutes.newAccount);
    if (context.mounted) _confirm(context, result);
  }

  static Future<void> _edit(
    BuildContext context,
    PaymentAccount account,
  ) async {
    final result = await context.push<AccountFormResult>(
      AppRoutes.editAccountFor(account.id),
    );
    if (context.mounted) _confirm(context, result);
  }

  static void _confirm(BuildContext context, AccountFormResult? result) {
    switch (result) {
      case AccountFormResult.created:
        FbuToast.show(context, PaymentAccountsStrings.saved);
      case AccountFormResult.updated:
        FbuToast.show(context, PaymentAccountsStrings.updated);
      case null:
        break;
    }
  }

  static Future<void> _open(
    BuildContext context,
    PaymentAccount account,
  ) async {
    final result = await showPaymentAccountSheet(context, account);
    if (!context.mounted) return;
    switch (result) {
      case AccountSheetResult.edit:
        await _edit(context, account);
      case AccountSheetResult.deleted:
        FbuToast.show(context, PaymentAccountsStrings.deleted);
      case null:
        break;
    }
  }

  /// Long press: copies the reference without format, with a light
  /// vibration. Cash has nothing to copy.
  static Future<void> _copy(
    BuildContext context,
    PaymentAccount account,
  ) async {
    if (!account.hasReference) {
      FbuToast.show(context, PaymentAccountsStrings.cashNotCopied);
      return;
    }
    await Clipboard.setData(ClipboardData(text: account.reference));
    await HapticFeedback.lightImpact();
    if (context.mounted) {
      FbuToast.show(
        context,
        PaymentAccountsStrings.copied(
          PaymentAccountRules.displayReference(account),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final accountsAsync = ref.watch(myPaymentAccountsProvider);
    final accounts = accountsAsync.value;
    final isEmpty = accounts != null && accounts.isEmpty;

    final Widget content;
    if (accounts != null) {
      content = isEmpty
          ? const Padding(
              padding: EdgeInsets.only(top: PaymentAccountsMetrics.emptyTopGap),
              child: AccountsEmptyState(),
            )
          : _AccountsList(
              accounts: accounts,
              onOpen: (a) => _open(context, a),
              onCopy: (a) => _copy(context, a),
            );
    } else if (accountsAsync.hasError && !accountsAsync.isLoading) {
      content = _LoadError(
        onRetry: () => ref.invalidate(myPaymentAccountsProvider),
      );
    } else {
      content = const Padding(
        padding: EdgeInsets.only(top: PaymentAccountsMetrics.listGap),
        child: AccountsSkeleton(),
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: padding.top + PaymentAccountsMetrics.barTop),
          AccountsTopBar(
            onAdd: accounts == null
                ? null
                : () => _add(context, accounts.length),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: PaymentAccountsMetrics.titleGap,
                bottom: isEmpty
                    ? tokens.space3
                    : padding.bottom + tokens.space3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.space3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            PaymentAccountsStrings.title,
                            style: styles.title,
                          ),
                        ),
                        if (!isEmpty) ...[
                          const SizedBox(
                            height: PaymentAccountsMetrics.subtitleGap,
                          ),
                          Text(
                            PaymentAccountsStrings.subtitle,
                            style: styles.subtitle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isEmpty
                          ? tokens.space3
                          : PaymentAccountsMetrics.listInset,
                    ),
                    child: content,
                  ),
                ],
              ),
            ),
          ),
          if (isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space3,
                tokens.space1,
                tokens.space3,
                padding.bottom + PaymentAccountsMetrics.bottomButtonGap,
              ),
              child: FbuPrimaryButton(
                onPressed: () => _add(context, 0),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: PaymentAccountsMetrics.buttonIconSize,
                    ),
                    SizedBox(width: PaymentAccountsMetrics.buttonIconGap),
                    Flexible(
                      child: Text(
                        PaymentAccountsStrings.add,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The card with the accounts and the long-press hint below it.
class _AccountsList extends StatelessWidget {
  const _AccountsList({
    required this.accounts,
    required this.onOpen,
    required this.onCopy,
  });

  final List<PaymentAccount> accounts;
  final ValueChanged<PaymentAccount> onOpen;
  final ValueChanged<PaymentAccount> onCopy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: PaymentAccountsMetrics.listGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountsCard(accounts: accounts, onOpen: onOpen, onCopy: onCopy),
          const SizedBox(height: PaymentAccountsMetrics.hintGap),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space3 - PaymentAccountsMetrics.listInset,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: PaymentAccountsMetrics.hintIconSize,
                  color: tokens.textSecondary,
                ),
                const SizedBox(width: PaymentAccountsMetrics.hintIconGap),
                Expanded(
                  child: Text(PaymentAccountsStrings.hint, style: styles.hint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "No pudimos cargar tus cuentas." with "Reintentar".
class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.space3 - PaymentAccountsMetrics.listInset,
        PaymentAccountsMetrics.listGap,
        tokens.space3 - PaymentAccountsMetrics.listInset,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              PaymentAccountsStrings.loadError,
              style: styles.subtitle,
            ),
          ),
          SizedBox(height: tokens.space2),
          FbuSecondaryButton(
            onPressed: onRetry,
            child: const Text(PaymentAccountsStrings.retry),
          ),
        ],
      ),
    );
  }
}
