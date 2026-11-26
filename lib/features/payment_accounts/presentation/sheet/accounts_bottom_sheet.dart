import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../payment_accounts_metrics.dart';

/// Shows a payment accounts bottom sheet: `surface` fill, radius 24 on top
/// with a 1 dp border, over a 60 % black scrim. It rises in 300 ms and goes
/// down in 220 ms (a plain 150 ms with `MediaQuery.disableAnimations`).
Future<T?> showAccountsBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final tokens = context.tokens;
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<T>(
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
    builder: builder,
  );
}

/// The 32×4 handle at the top of a sheet.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: PaymentAccountsMetrics.handleWidth,
        height: PaymentAccountsMetrics.handleHeight,
        decoration: BoxDecoration(
          color: context.tokens.outlineMuted,
          borderRadius: BorderRadius.circular(
            PaymentAccountsMetrics.handleRadius,
          ),
        ),
      ),
    );
  }
}
