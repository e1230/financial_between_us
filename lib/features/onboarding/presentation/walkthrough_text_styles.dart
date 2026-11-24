import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import 'walkthrough_metrics.dart';

/// Text styles of the walkthrough, derived from the app [TextTheme].
@immutable
class WalkthroughTextStyles {
  const WalkthroughTextStyles._({
    required this.title,
    required this.subtitle,
    required this.headerLabel,
  });

  factory WalkthroughTextStyles.of(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final layout = WalkthroughLayout.of(context);
    final subtitleBase = textTheme.bodyLarge!;
    return WalkthroughTextStyles._(
      // Satoshi Bold.
      title: textTheme.displaySmall!.copyWith(
        fontSize: layout.titleFontSize,
        height: layout.titleLineHeight / layout.titleFontSize,
        letterSpacing: layout.titleLetterSpacing,
        color: tokens.textPrimary,
      ),
      // Inter 16/24 w400 at 60 %.
      subtitle: subtitleBase.copyWith(
        height: tokens.space3 / subtitleBase.fontSize!,
        color: tokens.textSecondary,
      ),
      // Inter 15 w500.
      headerLabel: textTheme.labelMedium!.copyWith(
        fontSize: WalkthroughMetrics.headerLabelFontSize,
        color: tokens.textPrimary,
      ),
    );
  }

  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle headerLabel;
}
