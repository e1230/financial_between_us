import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../auth_metrics.dart';
import '../auth_text_styles.dart';

/// Green text link (Inter 14 w600) with a touch area at least 48 dp high.
class AuthLink extends StatelessWidget {
  const AuthLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final style = AuthTextStyles.of(context).link;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(
          AuthMetrics.touchTarget,
          AuthMetrics.touchTarget,
        ),
        tapTargetSize: MaterialTapTargetSize.padded,
        foregroundColor: tokens.accent,
        // Keeps the green while the form is busy (the whole row dims).
        disabledForegroundColor: tokens.accent,
        textStyle: style,
        shape: const StadiumBorder(),
      ),
      child: Text(label),
    );
  }
}

/// Footer line: "¿Ya tienes cuenta? **Inicia sesión**".
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.prompt,
    required this.linkLabel,
    required this.onPressed,
  });

  final String prompt;
  final String linkLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AuthMetrics.touchTarget),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AuthMetrics.footerGap,
        children: [
          Text(prompt, style: AuthTextStyles.of(context).footer),
          AuthLink(label: linkLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}
