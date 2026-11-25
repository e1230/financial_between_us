import 'dart:async';

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
import '../widgets/auth_scaffold.dart';
import '../widgets/fbu_text_field.dart';
import '../widgets/shake.dart';

/// Username (nickname) for whoever signs in with Google for the first time.
/// Built with the components of the sign-up screen (no design of its own).
///
/// Going back signs out, so the half-created session does not linger.
class ChooseUsernameScreen extends ConsumerStatefulWidget {
  const ChooseUsernameScreen({super.key});

  @override
  ConsumerState<ChooseUsernameScreen> createState() =>
      _ChooseUsernameScreenState();
}

class _ChooseUsernameScreenState extends ConsumerState<ChooseUsernameScreen>
    with AuthFormMixin<ChooseUsernameScreen> {
  final _username = AuthFieldState(
    field: AuthField.username,
    validator: AuthValidators.username,
  );

  String? _banner;

  @override
  List<AuthFieldState> get fields => [_username];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    setState(() => _banner = null);
    await runBusy(() async {
      try {
        final destination = await ref
            .read(authRepositoryProvider)
            .claimNickname(_username.text);
        if (!mounted) return;
        context.go(AppRoutes.forSession(destination));
      } on AuthFailure catch (failure) {
        if (!mounted) return;
        final message = AuthStrings.authFailure(failure);
        if (failure is NicknameTaken) {
          showFieldError(_username, message);
        } else {
          setState(() => _banner = message);
        }
      }
    });
  }

  void _onPopped(bool didPop, Object? result) {
    if (!didPop) return;
    unawaited(
      ref.read(authRepositoryProvider).signOut().catchError((Object _) {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = AuthTextStyles.of(context);
    final banner = _banner;
    return PopScope(
      onPopInvokedWithResult: _onPopped,
      child: AuthScaffold(
        busy: busy,
        children: [
          Text(AuthStrings.chooseUsernameTitle, style: styles.title),
          SizedBox(height: tokens.space1),
          Text(AuthStrings.chooseUsernameSubtitle, style: styles.subtitle),
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
                  controller: _username.controller,
                  focusNode: _username.focusNode,
                  label: AuthStrings.usernameLabel,
                  hint: AuthStrings.usernameHint,
                  errorText: _username.error,
                  autocorrect: false,
                  inputFormatters: usernameFormatters,
                  autofillHints: const [AutofillHints.newUsername],
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => onFieldChanged(_username),
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.space3),
          FbuPrimaryButton(
            onPressed: _submit,
            isLoading: busy,
            loadingSemanticsLabel: AuthStrings.saving,
            child: const Text(AuthStrings.continueLabel),
          ),
        ],
      ),
    );
  }
}
