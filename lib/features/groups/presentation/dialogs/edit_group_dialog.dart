import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../../../auth/presentation/widgets/fbu_text_field.dart';
import '../../../home/presentation/dialogs/dialog_parts.dart';
import '../../../home/presentation/dialogs/fbu_switch.dart';
import '../../../home/presentation/home_strings.dart';
import '../../data/groups_providers.dart';
import '../../domain/group.dart';
import '../../domain/group_failure.dart';
import '../../domain/group_settings.dart';
import '../../domain/group_validators.dart';
import '../groups_strings.dart';

/// "Editar grupo", for admins: name, approval of new members and password.
/// Completes with whether something was saved.
Future<bool> showEditGroupDialog(
  BuildContext context, {
  required Group group,
  required String uid,
}) async =>
    await showFbuDialog<bool>(
      context: context,
      builder: (_) => EditGroupDialog(group: group, uid: uid),
    ) ??
    false;

class EditGroupDialog extends ConsumerStatefulWidget {
  const EditGroupDialog({super.key, required this.group, required this.uid});

  /// The group as it was when the popup opened.
  final Group group;

  /// The admin editing it.
  final String uid;

  @override
  ConsumerState<EditGroupDialog> createState() => _EditGroupDialogState();
}

class _EditGroupDialogState extends ConsumerState<EditGroupDialog> {
  late final _name = TextEditingController(text: widget.group.name);
  final _password = TextEditingController();
  final _nameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late bool _requiresApproval = widget.group.requiresApproval;
  late bool _askPassword = widget.group.hasPassword;
  bool _submitted = false;
  bool _busy = false;
  GroupFailure? _failure;

  Group get _group => widget.group;

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _nameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  GroupFieldFailure? get _nameError => GroupValidators.name(_name.text);

  GroupFieldFailure? get _passwordError => GroupSettings.passwordError(
    group: _group,
    askPassword: _askPassword,
    newPassword: _password.text,
  );

  GroupSettings get _settings => GroupSettings.fromForm(
    group: _group,
    name: _name.text,
    requiresApproval: _requiresApproval,
    askPassword: _askPassword,
    newPassword: _password.text,
  );

  Future<void> _save() async {
    setState(() {
      _submitted = true;
      _failure = null;
    });
    if (_nameError != null || _passwordError != null) return;

    setState(() => _busy = true);
    try {
      await ref
          .read(groupsRepositoryProvider)
          .updateSettings(
            groupId: _group.id,
            adminUid: widget.uid,
            settings: _settings,
          );
    } on GroupFailure catch (failure) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failure = failure;
        });
      }
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  void _toggleAskPassword(bool value) {
    setState(() => _askPassword = value);
    // A group without a password needs one right away.
    if (value && !_group.hasPassword) _passwordFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final nameError = _submitted ? _nameError : null;
    final passwordError = _submitted ? _passwordError : null;
    final failure = _failure;
    final hadPassword = _group.hasPassword;

    return FbuDialog(
      semanticsLabel: GroupsStrings.editGroup,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DialogHeading(
            title: GroupsStrings.editGroup,
            subtitle: GroupsStrings.editSubtitle,
          ),
          SizedBox(height: tokens.space3),
          FbuTextField(
            controller: _name,
            focusNode: _nameFocus,
            label: HomeStrings.groupName,
            hint: HomeStrings.groupNameHint,
            errorText: nameError == null ? null : HomeStrings.field(nameError),
            enabled: !_busy,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              LengthLimitingTextInputFormatter(GroupValidators.maxNameLength),
            ],
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: tokens.space2),
          FbuSwitchRow(
            title: HomeStrings.approveMembers,
            text: GroupsStrings.approveMembersText,
            value: _requiresApproval,
            onChanged: _busy
                ? null
                : (value) => setState(() => _requiresApproval = value),
          ),
          FbuSwitchRow(
            title: GroupsStrings.askPassword,
            text: GroupsStrings.askPasswordText,
            value: _askPassword,
            onChanged: _busy ? null : _toggleAskPassword,
          ),
          if (_askPassword) ...[
            SizedBox(height: tokens.space1),
            FbuTextField(
              controller: _password,
              focusNode: _passwordFocus,
              label: hadPassword
                  ? GroupsStrings.newPassword
                  : HomeStrings.password,
              hint: hadPassword
                  ? GroupsStrings.keepPasswordHint
                  : GroupsStrings.passwordHint,
              helperText: hadPassword
                  ? GroupsStrings.changePasswordHelper
                  : HomeStrings.optionalPasswordHelper,
              errorText: passwordError == null
                  ? null
                  : HomeStrings.field(passwordError),
              isPassword: true,
              enabled: !_busy,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                LengthLimitingTextInputFormatter(
                  GroupValidators.maxPasswordLength,
                ),
              ],
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
            ),
          ],
          if (failure != null) ...[
            SizedBox(height: tokens.space2),
            AuthBanner(
              key: ValueKey(failure),
              message: HomeStrings.failure(failure),
            ),
          ],
          SizedBox(height: tokens.space3),
          FbuPrimaryButton(
            // Disabled until something changes. Turning the password on
            // counts, so an empty field shows why it cannot be saved.
            onPressed:
                _settings.changes(_group) || (_askPassword && !hadPassword)
                ? _save
                : null,
            isLoading: _busy,
            loadingSemanticsLabel: GroupsStrings.saving,
            child: const Text(GroupsStrings.saveChanges),
          ),
          SizedBox(height: tokens.space1),
          DialogCancelButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
