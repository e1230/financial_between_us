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

/// Sign-in with username or email and password.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
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

  /// Wrong credentials: both fields get a red border (message in the
  /// banner) until one of them changes.
  bool _credentialsRejected = false;

  /// The running request is Google's (the main button shows no spinner).
  bool _viaGoogle = false;

  @override
  List<AuthFieldState> get fields => [_identifier, _password];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    setState(() {
      _banner = null;
      _credentialsRejected = false;
    });
    await runBusy(() async {
      try {
        final destination = await ref
            .read(authRepositoryProvider)
            .signIn(identifier: _identifier.text, password: _password.text);
        if (!mounted) return;
        finishAutofill();
        context.go(AppRoutes.forSession(destination));
      } on AuthFailure catch (failure) {
        if (!mounted) return;
        setState(() {
          _banner = AuthStrings.authFailure(failure);
          _credentialsRejected = failure is InvalidCredentials;
        });
        if (_credentialsRejected) shakeKey.currentState?.shake();
      }
    });
  }

  void _onChanged(AuthFieldState field) {
    if (_credentialsRejected) setState(() => _credentialsRejected = false);
    onFieldChanged(field);
  }

  Future<void> _google() async {
    if (busy) return;
    setState(() {
      _banner = null;
      _credentialsRejected = false;
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
                    hasError: _credentialsRejected,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _onChanged(_identifier),
                  ),
                  const SizedBox(height: AuthMetrics.fieldGap),
                  FbuTextField(
                    controller: _password.controller,
                    focusNode: _password.focusNode,
                    label: AuthStrings.passwordLabel,
                    hint: AuthStrings.passwordHint,
                    errorText: _password.error,
                    hasError: _credentialsRejected,
                    isPassword: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _onChanged(_password),
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
          isLoading: busy && !_viaGoogle,
          loadingSemanticsLabel: AuthStrings.signingIn,
          child: const Text(AuthStrings.signIn),
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
