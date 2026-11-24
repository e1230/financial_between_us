import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';
import '../auth_text_styles.dart';
import '../widgets/auth_scaffold.dart';

/// Entry of the auth flow (background variant v1): create an account or
/// sign in. System back closes the app.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AuthScaffold(
      showBack: false,
      bottomGap: tokens.space2,
      children: [
        Text(AuthStrings.welcomeTitle, style: AuthTextStyles.of(context).title),
        SizedBox(height: tokens.space4),
        FbuPrimaryButton(
          onPressed: () => context.go(AppRoutes.register),
          child: const Text(AuthStrings.createAccount),
        ),
        const SizedBox(height: AuthMetrics.buttonGap),
        FbuSecondaryButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text(AuthStrings.signIn),
        ),
      ],
    );
  }
}
