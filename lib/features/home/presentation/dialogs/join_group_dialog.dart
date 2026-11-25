import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../../../auth/presentation/widgets/fbu_text_field.dart';
import '../../../groups/data/groups_providers.dart';
import '../../../groups/domain/group_code.dart';
import '../../../groups/domain/group_code_lookup.dart';
import '../../../groups/domain/group_failure.dart';
import '../../../groups/domain/group_validators.dart';
import '../../../groups/domain/join_outcome.dart';
import '../home_strings.dart';
import 'dialog_parts.dart';

/// "Unirme a un grupo": the code, then the password if the group has one,
/// and "Solicitud enviada" if the group requires approval. Joining a group
/// directly makes it the active one and closes the popup.
Future<void> showJoinGroupDialog(BuildContext context) => showFbuDialog<void>(
  context: context,
  builder: (_) => const JoinGroupDialog(),
);

enum _Step { code, password, requested }

class JoinGroupDialog extends ConsumerStatefulWidget {
  const JoinGroupDialog({super.key});

  @override
  ConsumerState<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends ConsumerState<JoinGroupDialog> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _codeFocus = FocusNode();
  final _passwordFocus = FocusNode();

  _Step _step = _Step.code;
  bool _busy = false;

  /// Message under the field of the current step.
  String? _fieldError;

  /// Network and unexpected errors, in a banner.
  GroupFailure? _failure;
  GroupCodeLookup? _group;

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _codeFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? get _uid => ref.read(authStateChangesProvider).value?.uid;

  void _show(GroupFailure failure) => setState(() {
    switch (failure) {
      case GroupCodeNotFound() || AlreadyMember() || WrongGroupPassword():
        _fieldError = HomeStrings.failure(failure);
        _failure = null;
      default:
        _fieldError = null;
        _failure = failure;
    }
  });

  Future<void> _run(Future<void> Function(String uid) action) async {
    final uid = _uid;
    if (uid == null) return;
    setState(() {
      _busy = true;
      _fieldError = null;
      _failure = null;
    });
    try {
      await action(uid);
    } on GroupFailure catch (failure) {
      if (mounted) _show(failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitCode() async {
    final code = GroupCode.normalize(_code.text);
    // Shows the code the way it is searched (`LIQ-7K4P`).
    _code.value = TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
    final invalid = GroupValidators.code(code);
    if (invalid != null) {
      setState(() => _fieldError = HomeStrings.field(invalid));
      return;
    }
    await _run((uid) async {
      final repository = ref.read(groupsRepositoryProvider);
      final group = await repository.lookupCode(code);
      if (await repository.isMember(groupId: group.groupId, uid: uid)) {
        throw const AlreadyMember();
      }
      _group = group;
      if (group.hasPassword) {
        if (!mounted) return;
        setState(() => _step = _Step.password);
        _passwordFocus.requestFocus();
        return;
      }
      await _join(uid, group, null);
    });
  }

  Future<void> _submitPassword() async {
    final group = _group;
    if (group == null) return;
    final invalid = GroupValidators.password(_password.text);
    if (invalid != null) {
      setState(() => _fieldError = HomeStrings.field(invalid));
      return;
    }
    await _run((uid) => _join(uid, group, _password.text));
  }

  Future<void> _join(
    String uid,
    GroupCodeLookup group,
    String? password,
  ) async {
    final outcome = await ref
        .read(groupsRepositoryProvider)
        .join(group: group, uid: uid, password: password);
    if (!mounted) return;
    switch (outcome) {
      case Joined(:final groupId):
        await ref.read(selectedGroupIdProvider.notifier).select(groupId);
        if (mounted) Navigator.of(context).pop();
      case PendingApproval():
        setState(() => _step = _Step.requested);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      _Step.code => HomeStrings.joinTitle,
      _Step.password => HomeStrings.passwordTitle,
      _Step.requested => HomeStrings.requestSentTitle,
    };
    return FbuDialog(
      semanticsLabel: title,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : context.tokens.motionShort,
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: switch (_step) {
            _Step.code => _codeStep(context),
            _Step.password => _passwordStep(context),
            _Step.requested => _requestedStep(context),
          },
        ),
      ),
    );
  }

  Widget _codeStep(BuildContext context) => _FormStep(
    heading: const DialogHeading(
      title: HomeStrings.joinTitle,
      subtitle: HomeStrings.joinSubtitle,
    ),
    field: FbuTextField(
      controller: _code,
      focusNode: _codeFocus,
      label: HomeStrings.groupCode,
      hint: HomeStrings.groupCodeHint,
      helperText: HomeStrings.groupCodeHelper,
      errorText: _fieldError,
      enabled: !_busy,
      autocorrect: false,
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      inputFormatters: const [_CodeInputFormatter()],
      onChanged: (_) {
        if (_fieldError != null) setState(() => _fieldError = null);
      },
      onSubmitted: (_) => _submitCode(),
    ),
    failure: _failure,
    busy: _busy,
    onSubmit: _submitCode,
  );

  Widget _passwordStep(BuildContext context) => _FormStep(
    heading: DialogHeading(
      title: HomeStrings.passwordTitle,
      subtitle: HomeStrings.passwordSubtitle(_group?.groupName ?? ''),
    ),
    field: FbuTextField(
      controller: _password,
      focusNode: _passwordFocus,
      label: HomeStrings.password,
      errorText: _fieldError,
      isPassword: true,
      enabled: !_busy,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      onChanged: (_) {
        if (_fieldError != null) setState(() => _fieldError = null);
      },
      onSubmitted: (_) => _submitPassword(),
    ),
    failure: _failure,
    busy: _busy,
    onSubmit: _submitPassword,
  );

  Widget _requestedStep(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogBadge(
          icon: Icons.schedule,
          color: palette.userSoft,
          background: palette.userTint,
        ),
        SizedBox(height: tokens.space3),
        DialogHeading(
          title: HomeStrings.requestSentTitle,
          subtitle: HomeStrings.requestSentText(_group?.groupName ?? ''),
        ),
        SizedBox(height: tokens.space3),
        FbuPrimaryButton(
          onPressed: Navigator.of(context).pop,
          child: const Text(HomeStrings.understood),
        ),
      ],
    );
  }
}

/// Heading, one field, an optional error banner, "Unirme" and "Cancelar".
class _FormStep extends StatelessWidget {
  const _FormStep({
    required this.heading,
    required this.field,
    required this.failure,
    required this.busy,
    required this.onSubmit,
  });

  final Widget heading;
  final Widget field;
  final GroupFailure? failure;
  final bool busy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final error = failure;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading,
        SizedBox(height: tokens.space3),
        field,
        if (error != null) ...[
          SizedBox(height: tokens.space2),
          AuthBanner(key: ValueKey(error), message: HomeStrings.failure(error)),
        ],
        SizedBox(height: tokens.space3),
        FbuPrimaryButton(
          onPressed: onSubmit,
          isLoading: busy,
          loadingSemanticsLabel: HomeStrings.joining,
          child: const Text(HomeStrings.join),
        ),
        SizedBox(height: tokens.space1),
        DialogCancelButton(onPressed: busy ? null : Navigator.of(context).pop),
      ],
    );
  }
}

/// Uppercases the join code as it is typed and keeps only its characters
/// (letters, digits and the hyphen), up to the length of a code.
class _CodeInputFormatter extends TextInputFormatter {
  const _CodeInputFormatter();

  static final RegExp _disallowed = RegExp('[^A-Z0-9-]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.toUpperCase().replaceAll(_disallowed, '');
    if (text.length > GroupCode.length) {
      text = text.substring(0, GroupCode.length);
    }
    final offset = newValue.selection.end.clamp(0, text.length);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
