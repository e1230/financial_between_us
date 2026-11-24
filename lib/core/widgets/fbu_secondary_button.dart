import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'fbu_pill_button.dart';

/// Full-width gray pill button for secondary actions.
///
/// Background [AppTokens.surfaceVariant] (pressed: [AppTokens.border]) and
/// text in [AppTokens.textPrimary]. When disabled only the text dims to
/// [AppTokens.textDisabled].
class FbuSecondaryButton extends StatelessWidget {
  const FbuSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.loadingSemanticsLabel,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final String? loadingSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return FbuPillButton(
      onPressed: onPressed,
      isLoading: isLoading,
      loadingSemanticsLabel: loadingSemanticsLabel,
      colors: FbuPillButtonColors(
        background: tokens.surfaceVariant,
        pressedBackground: tokens.border,
        disabledBackground: tokens.surfaceVariant,
        foreground: tokens.textPrimary,
        disabledForeground: tokens.textDisabled,
        ripple: tokens.textPrimary.withValues(
          alpha: FbuPillButton.rippleOpacity,
        ),
      ),
      child: child,
    );
  }
}
