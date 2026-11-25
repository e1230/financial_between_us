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
import '../auth_strings.dart';
import '../auth_text_styles.dart';
import '../widgets/auth_banner.dart';
import '../widgets/auth_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/fbu_text_field.dart';
import '../widgets/shake.dart';

/// Password reset: sends Firebase's reset email, whose link opens Firebase's
/// page where the new password is typed.
// DECISIÓN: handoff option B (no Hosting or App Links yet), so the "Nueva
// contraseña" field of the design is not shown.
// TODO: option A (new password typed in the app, applied when the link
// opens it) once Firebase Hosting and Android App Links are configured.
class RecoverScreen extends ConsumerStatefulWidget {
  const RecoverScreen({super.key});

  @override
  ConsumerState<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends ConsumerState<RecoverScreen>
    with AuthFormMixin<RecoverScreen> {
  final _email = AuthFieldState(
    field: AuthField.email,
    validator: AuthValidators.email,
  );

  /// Form-level notice (network error, expired link…).
  String? _banner;

  @override
  List<AuthFieldState> get fields => [_email];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    setState(() => _banner = null);
    final email = _email.text.trim();
    await runBusy(() async {
      try {
        // Unknown emails also go to "sent", so nobody can find out which
        // accounts exist.
        await ref.read(authRepositoryProvider).sendPasswordReset(email);
        if (!mounted) return;
        context.go(AppRoutes.recoverSent, extra: email);
      } on AuthFailure catch (failure) {
        if (mounted) setState(() => _banner = AuthStrings.authFailure(failure));
      }
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
              child: FbuTextField(
                controller: _email.controller,
                focusNode: _email.focusNode,
                label: AuthStrings.emailLabel,
                hint: AuthStrings.emailHint,
                errorText: _email.error,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.done,
                onChanged: (_) => onFieldChanged(_email),
                onSubmitted: (_) => _submit(),
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
