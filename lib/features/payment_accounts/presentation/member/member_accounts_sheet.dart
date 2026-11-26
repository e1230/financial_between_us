import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../../../../core/widgets/fbu_toast.dart';
import '../../data/payment_accounts_providers.dart';
import '../../domain/payment_account.dart';
import '../../domain/payment_account_rules.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import '../sheet/accounts_bottom_sheet.dart';
import '../widgets/accounts_card.dart';
import '../widgets/accounts_skeleton.dart';

/// Opens the payment accounts of the group member [uid] (whose visible
/// name is [name]) in a bottom sheet, to copy one and pay them.
Future<void> showMemberAccountsSheet(
  BuildContext context, {
  required String uid,
  required String name,
}) => showAccountsBottomSheet<void>(
  context: context,
  builder: (_) => MemberAccountsSheet(uid: uid, name: name),
);

/// Someone else's payment accounts, read-only: tapping (or long-pressing)
/// one copies its reference without format, with a light vibration and a
/// toast at the top (the sheet covers the bottom). Cash has nothing to copy.
class MemberAccountsSheet extends ConsumerWidget {
  const MemberAccountsSheet({super.key, required this.uid, required this.name});

  final String uid;

  /// Visible name of the member (may be empty while their profile loads).
  final String name;

  static Future<void> _copy(
    BuildContext context,
    PaymentAccount account,
  ) async {
    if (!account.hasReference) {
      FbuToast.show(
        context,
        PaymentAccountsStrings.cashNotCopied,
        position: FbuToastPosition.top,
      );
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
        position: FbuToastPosition.top,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final firstName = PaymentAccountRules.firstName(name);
    final accountsAsync = ref.watch(paymentAccountsOfProvider(uid));
    final accounts = accountsAsync.value;

    final Widget content;
    if (accounts != null) {
      content = accounts.isEmpty
          ? Text(
              firstName.isEmpty
                  ? PaymentAccountsStrings.memberEmptyFallback
                  : PaymentAccountsStrings.memberEmpty(firstName),
              style: styles.emptyText,
            )
          : AccountsCard(
              accounts: accounts,
              tapCopies: true,
              onOpen: (a) => _copy(context, a),
              onCopy: (a) => _copy(context, a),
            );
    } else if (accountsAsync.hasError && !accountsAsync.isLoading) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              PaymentAccountsStrings.memberLoadError,
              style: styles.subtitle,
            ),
          ),
          SizedBox(height: tokens.space2),
          FbuSecondaryButton(
            onPressed: () => ref.invalidate(paymentAccountsOfProvider(uid)),
            child: const Text(PaymentAccountsStrings.retry),
          ),
        ],
      );
    } else {
      content = const AccountsSkeleton(
        label: PaymentAccountsStrings.memberLoading,
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        tokens.space3,
        PaymentAccountsMetrics.sheetPaddingTop,
        tokens.space3,
        tokens.space5 + padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: PaymentAccountsMetrics.sheetHeaderGap),
          Semantics(
            header: true,
            child: Text(
              firstName.isEmpty
                  ? PaymentAccountsStrings.memberTitleFallback
                  : PaymentAccountsStrings.memberTitle(firstName),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: styles.sheetName,
            ),
          ),
          if (accounts != null && accounts.isNotEmpty) ...[
            const SizedBox(height: PaymentAccountsMetrics.subtitleGap),
            Text(
              PaymentAccountsStrings.memberSubtitle,
              style: styles.sheetType,
            ),
          ],
          SizedBox(height: tokens.space3),
          content,
        ],
      ),
    );
  }
}
