import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/auth_failure.dart';
import '../../../auth/presentation/auth_metrics.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../../../auth/presentation/widgets/fbu_text_field.dart';
import '../../../home/presentation/dialogs/dialog_parts.dart';
import '../../domain/profile_validators.dart';
import '../profile_strings.dart';

/// Popup to change the password of an email account. Completes with `true`
/// once the password was changed.
Future<bool> showChangePasswordDialog(BuildContext context) async =>
    await showFbuDialog<bool>(
      context: context,
      builder: (_) => const ChangePasswordDialog(),
    ) ??
    false;

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _currentFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _currentError;
  String? _newError;
  String? _confirmError;
  String? _banner;
  bool _busy = false;

  @override
  void dispose() {
    for (final controller in [_current, _new, _confirm]) {
      controller.dispose();
    }
    for (final node in [_currentFocus, _newFocus, _confirmFocus]) {
      node.dispose();
    }
    super.dispose();
  }

  static String? _message(ProfileFieldFailure? failure) =>
      failure == null ? null : ProfileStrings.field(failure);

  Future<void> _submit() async {
    if (_busy) return;
    final current = _current.text;
    final next = _new.text;
    setState(() {
      _banner = null;
      _currentError = _message(ProfileValidators.currentPassword(current));
      _newError = _message(
        ProfileValidators.newPassword(next, current: current),
      );
      _confirmError = _message(
        ProfileValidators.confirmPassword(_confirm.text, newPassword: next),
      );
    });
    if (_currentError != null) return _currentFocus.requestFocus();
    if (_newError != null) return _newFocus.requestFocus();
    if (_confirmError != null) return _confirmFocus.requestFocus();

    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(currentPassword: current, newPassword: next);
      if (mounted) Navigator.of(context).pop(true);
    } on InvalidCredentials {
      if (!mounted) return;
      setState(() => _currentError = ProfileStrings.wrongCurrentPassword);
      _currentFocus.requestFocus();
    } on AuthFailure catch (failure) {
      if (mounted) {
        setState(() => _banner = ProfileStrings.passwordFailure(failure));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String? error,
    required ValueChanged<String> onChanged,
    required TextInputAction action,
    required Iterable<String> autofill,
    String? helper,
  }) => FbuTextField(
    controller: controller,
    focusNode: focusNode,
    label: label,
    errorText: error,
    helperText: helper,
    isPassword: true,
    enabled: !_busy,
    autocorrect: false,
    autofillHints: autofill,
    textInputAction: action,
    onChanged: onChanged,
    onSubmitted: (_) => action == TextInputAction.done
        ? _submit()
        : FocusScope.of(context).nextFocus(),
  );

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final banner = _banner;
    return PopScope(
      canPop: !_busy,
      child: FbuDialog(
        semanticsLabel: ProfileStrings.changePasswordTitle,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DialogHeading(
                title: ProfileStrings.changePasswordTitle,
                subtitle: ProfileStrings.changePasswordSubtitle,
              ),
              if (banner != null) ...[
                SizedBox(height: tokens.space2),
                AuthBanner(key: ValueKey(banner), message: banner),
              ],
              SizedBox(height: tokens.space3),
              _field(
                controller: _current,
                focusNode: _currentFocus,
                label: ProfileStrings.currentPassword,
                error: _currentError,
                onChanged: (_) => setState(() => _currentError = null),
                action: TextInputAction.next,
                autofill: const [AutofillHints.password],
              ),
              const SizedBox(height: AuthMetrics.fieldGap),
              _field(
                controller: _new,
                focusNode: _newFocus,
                label: ProfileStrings.newPassword,
                error: _newError,
                helper: ProfileStrings.newPasswordHelper,
                onChanged: (_) => setState(() => _newError = null),
                action: TextInputAction.next,
                autofill: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: AuthMetrics.fieldGap),
              _field(
                controller: _confirm,
                focusNode: _confirmFocus,
                label: ProfileStrings.confirmPassword,
                error: _confirmError,
                onChanged: (_) => setState(() => _confirmError = null),
                action: TextInputAction.done,
                autofill: const [AutofillHints.newPassword],
              ),
              SizedBox(height: tokens.space3),
              FbuPrimaryButton(
                onPressed: _submit,
                isLoading: _busy,
                loadingSemanticsLabel: ProfileStrings.changingPassword,
                child: const Text(ProfileStrings.changePasswordAction),
              ),
              SizedBox(height: tokens.space1),
              DialogCancelButton(
                label: ProfileStrings.cancel,
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
