import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../auth/presentation/auth_metrics.dart';
import '../../../auth/presentation/auth_text_styles.dart';
import '../../domain/payment_account.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../widgets/payment_account_logo.dart';

/// Read-only "Tipo" field, styled like the filled text fields: the chosen
/// type (or "Elige un tipo") and its logo on the right. The type is picked
/// with the tiles below it.
///
/// A new logo enters with a 0.6 → 1 scale (ease-out-back, 180 ms) and a
/// fade; the old one fades out in 90 ms. With
/// `MediaQuery.disableAnimations` it only fades.
class TypeField extends StatelessWidget {
  const TypeField({super.key, required this.type});

  final PaymentAccountType? type;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = AuthTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final type = this.type;

    return Semantics(
      label: PaymentAccountsStrings.typeLabel,
      value: type?.label ?? PaymentAccountsStrings.typeHint,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: AuthMetrics.fieldHeight),
        padding: EdgeInsetsDirectional.only(
          start: tokens.space2,
          end: PaymentAccountsMetrics.typeFieldPaddingEnd,
        ),
        decoration: BoxDecoration(
          color: tokens.surfaceVariant,
          borderRadius: BorderRadius.circular(tokens.radiusInput),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AuthMetrics.fieldVerticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      PaymentAccountsStrings.typeLabel,
                      style: styles.fieldLabel,
                    ),
                    const SizedBox(height: AuthMetrics.fieldLabelGap),
                    Text(
                      type?.label ?? PaymentAccountsStrings.typeHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: type == null
                          ? styles.fieldValue.copyWith(
                              color: tokens.textDisabled,
                            )
                          : styles.fieldValue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: tokens.space1),
            AnimatedSwitcher(
              duration: reduceMotion
                  ? PaymentAccountsMetrics.reducedFade
                  : PaymentAccountsMetrics.logoSwitch,
              reverseDuration: reduceMotion
                  ? PaymentAccountsMetrics.reducedFade
                  : PaymentAccountsMetrics.logoSwitchOut,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: reduceMotion
                    ? child
                    : ScaleTransition(
                        scale:
                            Tween(
                                  begin: PaymentAccountsMetrics.morphStartScale,
                                  end: 1.0,
                                )
                                .chain(CurveTween(curve: Curves.easeOutBack))
                                .animate(animation),
                        child: child,
                      ),
              ),
              child: PaymentAccountLogo(key: ValueKey(type), type: type),
            ),
          ],
        ),
      ),
    );
  }
}
