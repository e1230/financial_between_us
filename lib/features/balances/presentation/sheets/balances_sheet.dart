import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../payment_accounts/presentation/sheet/accounts_bottom_sheet.dart';
import '../balances_metrics.dart';
import '../balances_text_styles.dart';

/// Shows a balances bottom sheet with the same frame as the payment
/// accounts ones: `surface`, radius 24 on top, 60 % scrim, 300 ms up and
/// 220 ms down.
Future<T?> showBalancesSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showAccountsBottomSheet<T>(context: context, builder: builder);

/// Content of a balances sheet: the handle, [title], [subtitle] and
/// [children], scrolling when they do not fit and above the keyboard.
/// [footer] (the main button) stays below the scrolling part.
class BalancesSheetFrame extends StatelessWidget {
  const BalancesSheetFrame({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final subtitle = this.subtitle;
    final footer = this.footer;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                tokens.space3,
                BalancesMetrics.sheetPaddingTop,
                tokens.space3,
                footer == null ? tokens.space5 + padding.bottom : tokens.space2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetHandle(),
                  const SizedBox(height: BalancesMetrics.sheetHeaderGap),
                  Semantics(
                    header: true,
                    child: Text(title, style: styles.sheetTitle),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: styles.sheetSubtitle,
                    ),
                  SizedBox(height: tokens.space3),
                  ...children,
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space3,
                tokens.space1,
                tokens.space3,
                tokens.space3 + (keyboard > 0 ? 0 : padding.bottom),
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}

/// The 60 % notice of a sheet, with an info icon.
class SheetNotice extends StatelessWidget {
  const SheetNotice(this.text, {super.key});

  final String text;

  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: _iconSize, color: tokens.textSecondary),
        SizedBox(width: tokens.space1),
        Expanded(child: Text(text, style: styles.body)),
      ],
    );
  }
}

/// An error under a form, announced by screen readers.
class SheetError extends StatelessWidget {
  const SheetError(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final styles = BalancesTextStyles.of(context);
    return Semantics(
      liveRegion: true,
      child: Text(
        text,
        style: styles.body.copyWith(color: context.tokens.negative),
      ),
    );
  }
}
