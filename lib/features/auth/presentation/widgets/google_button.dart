import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/fbu_secondary_button.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';

/// "Continuar con Google": secondary button with the official Google "G"
/// (sign-in branding kit) 12 dp before the text.
class GoogleButton extends StatelessWidget {
  const GoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;

  /// Spinner while Firebase finishes the Google sign-in.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FbuSecondaryButton(
      onPressed: onPressed,
      isLoading: isLoading,
      loadingSemanticsLabel: AuthStrings.signingIn,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(
            image: AssetImage(AuthMetrics.googleLogoAsset),
            width: AuthMetrics.googleLogoSize,
            height: AuthMetrics.googleLogoSize,
            excludeFromSemantics: true,
          ),
          SizedBox(width: AuthMetrics.googleLogoGap),
          Flexible(
            child: Text(
              AuthStrings.continueWithGoogle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
