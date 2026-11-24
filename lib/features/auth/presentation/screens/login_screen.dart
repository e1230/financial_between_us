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

/// Sign-in with username or email and password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with AuthFormMixin<LoginScreen> {
  final _identifier = AuthFieldState(
    field: AuthField.loginIdentifier,
    validator: AuthValidators.required,
  );
  final _password = AuthFieldState(
    field: AuthField.loginPassword,
    validator: AuthValidators.required,
  );

  /// Form-level notice (wrong credentials, network…), 24 dp below the
  /// subtitle.
  String? _banner;

  @override
  List<AuthFieldState> get fields => [_identifier, _password];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    setState(() => _banner = null);
    await runBusy(() async {
      // TODO: sign in with email, or look up the email of the username
      // first (handoff section 6.3). Errors go to `_banner`.
      await simulateAuthRequest();
      if (!mounted) return;
      finishAutofill();
      context.go(AppRoutes.home);
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
        Text(AuthStrings.loginTitle, style: styles.title),
        SizedBox(height: tokens.space1),
        Text(AuthStrings.loginSubtitle, style: styles.subtitle),
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
                    controller: _identifier.controller,
                    focusNode: _identifier.focusNode,
                    label: AuthStrings.loginIdentifierLabel,
                    hint: AuthStrings.loginIdentifierHint,
                    errorText: _identifier.error,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => onFieldChanged(_identifier),
                  ),
                  const SizedBox(height: AuthMetrics.fieldGap),
                  FbuTextField(
                    controller: _password.controller,
                    focusNode: _password.focusNode,
                    label: AuthStrings.passwordLabel,
                    hint: AuthStrings.passwordHint,
                    errorText: _password.error,
                    isPassword: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => onFieldChanged(_password),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: AuthMetrics.fieldGap),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AuthLink(
                      label: AuthStrings.forgotPassword,
                      onPressed: () => context.go(AppRoutes.recover),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.space1),
        FbuPrimaryButton(
          onPressed: _submit,
          isLoading: busy,
          loadingSemanticsLabel: AuthStrings.signingIn,
          child: const Text(AuthStrings.signIn),
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
                prompt: AuthStrings.loginFooter,
                linkLabel: AuthStrings.loginFooterLink,
                onPressed: () => context.go(AppRoutes.register),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
