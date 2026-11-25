import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_failure.dart';
import '../../domain/auth_validators.dart';
import '../auth_form.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';
import '../auth_text_styles.dart';
import '../google_sign_in_action.dart';
import '../widgets/auth_banner.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/fbu_text_field.dart';
import '../widgets/google_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/shake.dart';

/// Sign-up with username, email and password.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
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

  /// The running request is Google's (the main button shows no spinner).
  bool _viaGoogle = false;

  @override
  List<AuthFieldState> get fields => [_username, _email, _password];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    setState(() => _banner = null);
    await runBusy(() async {
      try {
        final destination = await ref
            .read(authRepositoryProvider)
            .register(
              nickname: _username.text,
              email: _email.text,
              password: _password.text,
            );
        if (!mounted) return;
        finishAutofill();
        context.go(AppRoutes.forSession(destination));
      } on AuthFailure catch (failure) {
        if (mounted) _showFailure(failure);
      }
    });
  }

  void _showFailure(AuthFailure failure) {
    final message = AuthStrings.authFailure(failure);
    switch (failure) {
      case NicknameTaken():
        showFieldError(_username, message);
      case EmailAlreadyInUse():
        showFieldError(_email, message);
      case WeakPassword():
        showFieldError(_password, message);
      default:
        setState(() => _banner = message);
    }
  }

  Future<void> _google() async {
    if (busy) return;
    setState(() {
      _banner = null;
      _viaGoogle = true;
    });
    await runBusy(() async {
      final error = await continueWithGoogle(context, ref);
      if (mounted) setState(() => _banner = error);
    });
    if (mounted) setState(() => _viaGoogle = false);
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
          isLoading: busy && !_viaGoogle,
          loadingSemanticsLabel: AuthStrings.creatingAccount,
          child: const Text(AuthStrings.createAccount),
        ),
        BusyFade(
          busy: busy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const OrDivider(),
              GoogleButton(onPressed: _google, isLoading: _viaGoogle),
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
