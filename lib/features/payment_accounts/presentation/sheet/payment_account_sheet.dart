import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/platform/share_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../../../../core/widgets/fbu_toast.dart';
import '../../../profile/data/profile_providers.dart';
import '../../data/payment_accounts_providers.dart';
import '../../domain/payment_account.dart';
import '../../domain/payment_account_rules.dart';
import '../dialogs/delete_account_dialog.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import '../widgets/payment_account_logo.dart';
import 'copy_button.dart';
import 'reference_box.dart';
import 'sheet_menu_button.dart';

/// What the user chose in the detail, for the list to act on.
enum AccountSheetResult {
  /// "Editar": the list opens the form.
  edit,

  /// Deleted: the list shows "Cuenta eliminada".
  deleted,
}

/// Opens the detail of [account] as a modal bottom sheet over a 60 %
/// black scrim. It rises in 300 ms and goes down in 220 ms (a plain
/// 150 ms with `MediaQuery.disableAnimations`).
Future<AccountSheetResult?> showPaymentAccountSheet(
  BuildContext context,
  PaymentAccount account,
) {
  final tokens = context.tokens;
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<AccountSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: tokens.surface,
    barrierColor: tokens.brandBackground.withValues(
      alpha: PaymentAccountsMetrics.scrimOpacity,
    ),
    showDragHandle: false,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(PaymentAccountsMetrics.sheetRadius),
      ),
      side: BorderSide(color: tokens.border),
    ),
    clipBehavior: Clip.antiAlias,
    sheetAnimationStyle: AnimationStyle(
      duration: reduceMotion
          ? PaymentAccountsMetrics.reducedFade
          : PaymentAccountsMetrics.sheetEntry,
      reverseDuration: reduceMotion
          ? PaymentAccountsMetrics.reducedFade
          : PaymentAccountsMetrics.sheetExit,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
    builder: (_) => PaymentAccountSheet(account: account),
  );
}

/// Detail of a payment account: logo, name and type, the reference box,
/// "Copiar" (not for cash) and "Compartir", and the ⋮ menu with "Editar"
/// and "Eliminar".
class PaymentAccountSheet extends ConsumerWidget {
  const PaymentAccountSheet({super.key, required this.account});

  /// The account when the sheet opened; live changes replace it.
  final PaymentAccount account;

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    PaymentAccount a,
  ) async {
    final displayName =
        ref.read(currentUserProfileProvider).value?.displayName ?? '';
    final text = PaymentAccountsStrings.shareText(
      a,
      PaymentAccountRules.firstName(displayName),
    );
    try {
      await ref.read(shareServiceProvider).shareText(text);
    } catch (_) {
      if (context.mounted) {
        FbuToast.show(
          context,
          PaymentAccountsStrings.shareError,
          position: FbuToastPosition.top,
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, PaymentAccount a) async {
    final deleted = await showDeleteAccountDialog(context, a);
    if (deleted && context.mounted) {
      Navigator.of(context).pop(AccountSheetResult.deleted);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    // The latest version of the account (e.g. after an edit elsewhere).
    final current =
        ref
            .watch(myPaymentAccountsProvider)
            .value
            ?.where((a) => a.id == account.id)
            .firstOrNull ??
        account;

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
          Center(
            child: Container(
              width: PaymentAccountsMetrics.handleWidth,
              height: PaymentAccountsMetrics.handleHeight,
              decoration: BoxDecoration(
                color: tokens.outlineMuted,
                borderRadius: BorderRadius.circular(
                  PaymentAccountsMetrics.handleRadius,
                ),
              ),
            ),
          ),
          const SizedBox(height: PaymentAccountsMetrics.sheetHeaderGap),
          Row(
            children: [
              // DECISIÓN: no Hero from the row. Flutter only flies heroes
              // between page routes, and a bottom sheet is a popup route;
              // the logo pops in with the sheet instead.
              _LogoEntrance(
                child: PaymentAccountLogo(
                  type: current.type,
                  size: PaymentAccountLogoSize.large,
                ),
              ),
              const SizedBox(width: PaymentAccountsMetrics.sheetLogoGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        current.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.sheetName,
                      ),
                    ),
                    Text(current.type.label, style: styles.sheetType),
                  ],
                ),
              ),
              SheetMenuButton(
                onEdit: () =>
                    Navigator.of(context).pop(AccountSheetResult.edit),
                onDelete: () => _delete(context, current),
              ),
            ],
          ),
          const SizedBox(height: PaymentAccountsMetrics.boxGap),
          ReferenceBox(account: current),
          const SizedBox(height: PaymentAccountsMetrics.boxGap),
          if (current.hasReference) ...[
            CopyButton(reference: current.reference),
            const SizedBox(height: PaymentAccountsMetrics.buttonsGap),
          ],
          FbuSecondaryButton(
            onPressed: () => _share(context, ref, current),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.share_outlined,
                  size: PaymentAccountsMetrics.buttonIconSize,
                ),
                SizedBox(width: PaymentAccountsMetrics.buttonIconGap),
                Flexible(
                  child: Text(
                    PaymentAccountsStrings.share,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The big logo scales from 0.6 to 1 (ease-out-back, 300 ms) as the sheet
/// opens. With `MediaQuery.disableAnimations` it only fades in.
class _LogoEntrance extends StatelessWidget {
  const _LogoEntrance({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduceMotion
          ? PaymentAccountsMetrics.reducedFade
          : PaymentAccountsMetrics.sheetEntry,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: reduceMotion
            ? child
            : Transform.scale(
                scale:
                    PaymentAccountsMetrics.morphStartScale +
                    (1 - PaymentAccountsMetrics.morphStartScale) *
                        Curves.easeOutBack.transform(t),
                child: child,
              ),
      ),
      child: child,
    );
  }
}
