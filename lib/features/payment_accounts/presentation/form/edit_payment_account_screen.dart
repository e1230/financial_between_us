import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../../data/payment_accounts_providers.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import 'payment_account_form_screen.dart';

/// "Editar cuenta" of the account [accountId]: the form once the account
/// is known, or a short message if it no longer exists.
class EditPaymentAccountScreen extends ConsumerWidget {
  const EditPaymentAccountScreen({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(myPaymentAccountByIdProvider(accountId));
    return switch (account) {
      AsyncData(value: final account?) => PaymentAccountFormScreen(
        initial: account,
      ),
      AsyncData() || AsyncError() => const _Missing(),
      _ => Scaffold(backgroundColor: context.tokens.background),
    };
  }
}

/// The account was deleted (or could not be loaded).
class _Missing extends StatelessWidget {
  const _Missing();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(PaymentAccountsStrings.notFound, style: styles.emptyTitle),
              const SizedBox(height: PaymentAccountsMetrics.emptyTitleGap),
              FbuSecondaryButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text(PaymentAccountsStrings.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
