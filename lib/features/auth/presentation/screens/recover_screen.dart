import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../domain/auth_validators.dart';
import '../auth_form.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';
import '../auth_text_styles.dart';
import '../widgets/auth_banner.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/fbu_text_field.dart';
import '../widgets/shake.dart';

/// Password reset: email plus the new password, applied when the user opens
/// the link of the email.
class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen>
    with AuthFormMixin<RecoverScreen> {
  final _email = AuthFieldState(
    field: AuthField.email,
    validator: AuthValidators.email,
  );
  final _password = AuthFieldState(
    field: AuthField.password,
    validator: AuthValidators.newPassword,
  );

  /// Form-level notice (network error, expired link…).
  String? _banner;

  @override
  List<AuthFieldState> get fields => [_email, _password];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    setState(() => _banner = null);
    final email = _email.text.trim();
    await runBusy(() async {
      // TODO: store the pending password and send the reset email
      // (handoff section 6.5). Always go to "sent", even for unknown emails.
      await simulateAuthRequest();
      if (!mounted) return;
      context.go(AppRoutes.recoverSent, extra: email);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = AuthTextStyles.of(context);
    final banner = _banner;
    return AuthScaffold(
      busy: busy,
      children: [
        Text(AuthStrings.recoverTitle, style: styles.title),
        SizedBox(height: tokens.space1),
        Text(AuthStrings.recoverSubtitle, style: styles.subtitle),
        SizedBox(height: tokens.space3),
        if (banner != null) ...[
          AuthBanner(key: ValueKey(banner), message: banner),
          SizedBox(height: tokens.space2),
        ],
        BusyFade(
          busy: busy,
          child: Shake(
            key: shakeKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FbuTextField(
                    controller: _email.controller,
                    focusNode: _email.focusNode,
                    label: AuthStrings.emailLabel,
                    hint: AuthStrings.emailHint,
                    errorText: _email.error,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => onFieldChanged(_email),
                  ),
                  const SizedBox(height: AuthMetrics.fieldGap),
                  FbuTextField(
                    controller: _password.controller,
                    focusNode: _password.focusNode,
                    label: AuthStrings.newPasswordLabel,
                    hint: AuthStrings.passwordHint,
                    helperText: AuthStrings.passwordHelper,
                    errorText: _password.error,
                    isPassword: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => onFieldChanged(_password),
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.space3),
        FbuPrimaryButton(
          onPressed: _submit,
          isLoading: busy,
          loadingSemanticsLabel: AuthStrings.sending,
          child: const Text(AuthStrings.send),
        ),
        SizedBox(height: tokens.space1),
        BusyFade(
          busy: busy,
          child: AuthFooter(
            prompt: AuthStrings.recoverFooter,
            linkLabel: AuthStrings.signInLink,
            onPressed: () => context.go(AppRoutes.login),
          ),
        ),
      ],
    );
  }
}
