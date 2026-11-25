import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../../../auth/presentation/widgets/fbu_text_field.dart';
import '../../../groups/data/groups_providers.dart';
import '../../../groups/domain/group_code_lookup.dart';
import '../../../groups/domain/group_failure.dart';
import '../../../groups/domain/group_validators.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';
import 'dialog_parts.dart';
import 'fbu_switch.dart';
import 'group_created_view.dart';

/// "Crear grupo": name, optional password and approval of new members.
/// On success the popup turns into "Grupo creado" with the join code, and
/// the new group becomes the active one.
Future<void> showCreateGroupDialog(BuildContext context) => showFbuDialog<void>(
  context: context,
  builder: (_) => const CreateGroupDialog(),
);

class CreateGroupDialog extends ConsumerStatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  ConsumerState<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends ConsumerState<CreateGroupDialog> {
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _nameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _requiresApproval = false;
  bool _submitted = false;
  bool _busy = false;
  GroupFailure? _failure;
  CreatedGroup? _created;

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _nameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  GroupFieldFailure? get _nameError => GroupValidators.name(_name.text);
  GroupFieldFailure? get _passwordError =>
      GroupValidators.optionalPassword(_password.text);

  Future<void> _create() async {
    setState(() {
      _submitted = true;
      _failure = null;
    });
    if (_nameError != null || _passwordError != null) return;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;

    setState(() => _busy = true);
    try {
      final created = await ref
          .read(groupsRepositoryProvider)
          .createGroup(
            uid: uid,
            name: _name.text,
            password: _password.text,
            requiresApproval: _requiresApproval,
          );
      // The new group is the active one as soon as it exists.
      await ref.read(selectedGroupIdProvider.notifier).select(created.groupId);
      if (mounted) setState(() => _created = created);
    } on GroupFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final created = _created;
    return FbuDialog(
      semanticsLabel: created == null
          ? HomeStrings.createTitle
          : HomeStrings.createdTitle,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : context.tokens.motionShort,
        child: created == null
            ? _form(context)
            : GroupCreatedView(
                key: const ValueKey('created'),
                group: created,
                onDone: Navigator.of(context).pop,
              ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final nameError = _submitted ? _nameError : null;
    final passwordError = _submitted ? _passwordError : null;
    final failure = _failure;
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DialogHeading(
          title: HomeStrings.createTitle,
          subtitle: HomeStrings.createSubtitle,
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
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(GroupValidators.maxNameLength),
          ],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        SizedBox(height: tokens.space2),
        FbuTextField(
          controller: _password,
          focusNode: _passwordFocus,
          label: HomeStrings.optionalPassword,
          hint: HomeStrings.optionalPasswordHint,
          helperText: HomeStrings.optionalPasswordHelper,
          errorText: passwordError == null
              ? null
              : HomeStrings.field(passwordError),
          isPassword: true,
          enabled: !_busy,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            LengthLimitingTextInputFormatter(GroupValidators.maxPasswordLength),
          ],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _create(),
        ),
        SizedBox(height: tokens.space2),
        MergeSemantics(
          child: InkWell(
            onTap: _busy
                ? null
                : () => setState(() => _requiresApproval = !_requiresApproval),
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.space1),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          HomeStrings.approveMembers,
                          style: styles.cardTitle,
                        ),
                        Text(
                          HomeStrings.approveMembersText,
                          style: styles.dialogSubtitle,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: tokens.space2),
                  Semantics(
                    toggled: _requiresApproval,
                    child: FbuSwitch(value: _requiresApproval),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (failure != null) ...[
          SizedBox(height: tokens.space2),
          AuthBanner(
            key: ValueKey(failure),
            message: HomeStrings.failure(failure),
          ),
        ],
        SizedBox(height: tokens.space3),
        FbuPrimaryButton(
          onPressed: _create,
          isLoading: _busy,
          loadingSemanticsLabel: HomeStrings.creating,
          child: const Text(HomeStrings.createTitle),
        ),
        SizedBox(height: tokens.space1),
        DialogCancelButton(onPressed: _busy ? null : Navigator.of(context).pop),
      ],
    );
  }
}
