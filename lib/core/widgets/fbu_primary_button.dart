import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'fbu_pill_button.dart';

/// Full-width green pill button used for the main action of a screen.
///
/// Pressed state: [AppTokens.accentPressed] background and a 0.97 scale.
/// While [isLoading] it shows a spinner in [AppTokens.onAccent] and ignores
/// taps. Honors `MediaQuery.disableAnimations`.
class FbuPrimaryButton extends StatelessWidget {
  const FbuPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.loadingSemanticsLabel,
  });

  final VoidCallback? onPressed;

  /// Usually a [Text]; styled with `labelLarge` in [AppTokens.onAccent].
  final Widget child;
  final bool isLoading;
  final String? loadingSemanticsLabel;

  /// Height of the button.
  static const double height = FbuPillButton.height;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return FbuPillButton(
      onPressed: onPressed,
      isLoading: isLoading,
      loadingSemanticsLabel: loadingSemanticsLabel,
      colors: FbuPillButtonColors(
        background: tokens.accent,
        pressedBackground: tokens.accentPressed,
        disabledBackground: tokens.surfaceVariant,
        foreground: tokens.onAccent,
        disabledForeground: tokens.textDisabled,
        ripple: tokens.onAccent.withValues(alpha: FbuPillButton.rippleOpacity),
      ),
      child: child,
    );
  }
}
