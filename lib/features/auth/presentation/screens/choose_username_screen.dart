import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../domain/auth_validators.dart';
import '../auth_form.dart';
import '../auth_strings.dart';
import '../auth_text_styles.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/fbu_text_field.dart';
import '../widgets/shake.dart';

/// Username for whoever signs in with Google for the first time. Built
/// with the components of the sign-up screen (no design of its own).
class ChooseUsernameScreen extends StatefulWidget {
  const ChooseUsernameScreen({super.key});

  @override
  State<ChooseUsernameScreen> createState() => _ChooseUsernameScreenState();
}

class _ChooseUsernameScreenState extends State<ChooseUsernameScreen>
    with AuthFormMixin<ChooseUsernameScreen> {
  final _username = AuthFieldState(
    field: AuthField.username,
    validator: AuthValidators.username,
  );

  @override
  List<AuthFieldState> get fields => [_username];

  Future<void> _submit() async {
    if (busy || !validateAll()) return;
    await runBusy(() async {
      // TODO: reserve the username in a transaction and create users/{uid}
      // (handoff section 6.4). Back must also sign out of Google.
      await simulateAuthRequest();
      if (!mounted) return;
      context.go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = AuthTextStyles.of(context);
    return AuthScaffold(
      busy: busy,
      children: [
        Text(AuthStrings.chooseUsernameTitle, style: styles.title),
        SizedBox(height: tokens.space1),
        Text(AuthStrings.chooseUsernameSubtitle, style: styles.subtitle),
        SizedBox(height: tokens.space3),
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
    );
  }
}
