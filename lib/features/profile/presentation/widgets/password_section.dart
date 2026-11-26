import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../auth/domain/sign_in_method.dart';
import '../../../auth/presentation/auth_metrics.dart';
import '../profile_metrics.dart';
import '../profile_strings.dart';
import 'profile_info_tile.dart';

/// Password row of the profile. Email accounts can change it ("Cambiar");
/// Google accounts only see "Ingresado con Google". Nothing while the sign-in
/// method is unknown.
class PasswordSection extends StatelessWidget {
  const PasswordSection({
    super.key,
    required this.method,
    required this.onChangePassword,
    this.enabled = true,
  });

  final SignInMethod? method;
  final VoidCallback onChangePassword;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return switch (method) {
      null => const SizedBox.shrink(),
      SignInMethod.password => ProfileInfoTile(
        label: ProfileStrings.passwordLabel,
        value: ProfileStrings.passwordMask,
        trailing: SizedBox(
          height: AuthMetrics.touchTarget,
          child: TextButton(
            onPressed: enabled ? onChangePassword : null,
            style: TextButton.styleFrom(
              foregroundColor: tokens.accent,
              disabledForegroundColor: tokens.textDisabled,
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Semantics(
              label: ProfileStrings.changePasswordAction,
              child: const ExcludeSemantics(
                child: Text(ProfileStrings.changePassword),
              ),
            ),
          ),
        ),
      ),
      SignInMethod.google => ProfileInfoTile(
        label: ProfileStrings.passwordLabel,
        value: ProfileStrings.signedInWithGoogle,
        helper: ProfileStrings.googlePasswordHelper,
        leading: Image.asset(
          AuthMetrics.googleLogoAsset,
          width: ProfileMetrics.googleLogoSize,
          height: ProfileMetrics.googleLogoSize,
          excludeFromSemantics: true,
        ),
      ),
    };
  }
}
