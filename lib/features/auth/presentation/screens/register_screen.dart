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
import '../widgets/google_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/shake.dart';

/// Sign-up with username, email and password.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with AuthFormMixin<RegisterScreen> {
  final _username = AuthFieldState(
    field: AuthField.username,
    validator: AuthValidators.username,
  );
  final _email = AuthFieldState(
    field: AuthField.email,
    validator: AuthValidators.email,
  );
  final _password = AuthFieldState(
    field: AuthField.password,
    validator: AuthValidators.newPassword,
  );

  /// Form-level error (Firebase), shown where a subtitle would be.
  String? _banner;

  @override
  List<AuthFieldState> get fields => [_username, _email, _password];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    setState(() => _banner = null);
    await runBusy(() async {
      // TODO: check the username, create the account and reserve the
      // username in a transaction (handoff section 6.2).
      await simulateAuthRequest();
      if (!mounted) return;
      finishAutofill();
      context.go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final banner = _banner;
    return AuthScaffold(
      busy: busy,
      children: [
        Text(
          AuthStrings.registerTitle,
          style: AuthTextStyles.of(context).title,
        ),
        if (banner != null) ...[
          SizedBox(height: tokens.space3),
          AuthBanner(key: ValueKey(banner), message: banner),
          SizedBox(height: tokens.space2),
        ] else
          SizedBox(height: tokens.space3),
        BusyFade(
          busy: busy,
          child: Shake(
            key: shakeKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FbuTextField(
                    controller: _username.controller,
                    focusNode: _username.focusNode,
                    label: AuthStrings.usernameLabel,
                    hint: AuthStrings.usernameHint,
                    errorText: _username.error,
                    autocorrect: false,
                    inputFormatters: usernameFormatters,
                    autofillHints: const [AutofillHints.newUsername],
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => onFieldChanged(_username),
                  ),
                  const SizedBox(height: AuthMetrics.fieldGap),
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
                    label: AuthStrings.passwordLabel,
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
          loadingSemanticsLabel: AuthStrings.creatingAccount,
          child: const Text(AuthStrings.createAccount),
        ),
        BusyFade(
          busy: busy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OrDivider(),
              // TODO: Google sign-in; the first time it asks for a username.
              GoogleButton(
                onPressed: () => context.go(AppRoutes.chooseUsername),
              ),
              SizedBox(height: tokens.space1),
              AuthFooter(
                prompt: AuthStrings.registerFooter,
                linkLabel: AuthStrings.signInLink,
                onPressed: () => context.go(AppRoutes.login),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
