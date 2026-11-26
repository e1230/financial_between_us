import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_pill_button.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../../../home/presentation/dialogs/dialog_parts.dart';
import '../../../home/presentation/home_strings.dart';
import '../../domain/group_failure.dart';
import '../groups_strings.dart';

/// Asks before the admin removes [name] from the group. [hasPendingBalance]
/// adds a warning (removing is still allowed). Completes with whether the
/// member was removed.
Future<bool> showRemoveMemberDialog(
  BuildContext context, {
  required String name,
  required bool hasPendingBalance,
  required Future<void> Function() onConfirm,
}) => _show(
  context,
  MemberActionDialog(
    title: GroupsStrings.removeTitle(name),
    text: GroupsStrings.removeText,
    warning: hasPendingBalance ? GroupsStrings.pendingBalanceWarning : null,
    confirmLabel: GroupsStrings.removeMember,
    busyLabel: GroupsStrings.removing,
    onConfirm: onConfirm,
  ),
);

/// Asks before the admin rejects the request of [name].
Future<bool> showRejectRequestDialog(
  BuildContext context, {
  required String name,
  required Future<void> Function() onConfirm,
}) => _show(
  context,
  MemberActionDialog(
    title: GroupsStrings.rejectTitle(name),
    text: GroupsStrings.rejectText,
    confirmLabel: GroupsStrings.reject,
    busyLabel: GroupsStrings.rejecting,
    onConfirm: onConfirm,
  ),
);

/// Asks before an admin makes [name] an admin too.
Future<bool> showPromoteMemberDialog(
  BuildContext context, {
  required String name,
  required Future<void> Function() onConfirm,
}) => _show(
  context,
  MemberActionDialog(
    title: GroupsStrings.promoteTitle(name),
    text: GroupsStrings.promoteText,
    confirmLabel: GroupsStrings.promote,
    busyLabel: GroupsStrings.promoting,
    destructive: false,
    onConfirm: onConfirm,
  ),
);

/// Asks before the owner turns the admin [name] back into a plain member.
Future<bool> showDemoteMemberDialog(
  BuildContext context, {
  required String name,
  required Future<void> Function() onConfirm,
}) => _show(
  context,
  MemberActionDialog(
    title: GroupsStrings.demoteTitle(name),
    text: GroupsStrings.demoteText,
    confirmLabel: GroupsStrings.demote,
    busyLabel: GroupsStrings.demoting,
    onConfirm: onConfirm,
  ),
);

Future<bool> _show(BuildContext context, Widget dialog) async =>
    await showFbuDialog<bool>(context: context, builder: (_) => dialog) ??
    false;

/// Confirmation of an admin action on a member, red when [destructive].
/// Runs [onConfirm] and closes; on a [GroupFailure] it shows a banner and
/// stays open.
class MemberActionDialog extends StatefulWidget {
  const MemberActionDialog({
    super.key,
    required this.title,
    required this.text,
    required this.confirmLabel,
    required this.busyLabel,
    required this.onConfirm,
    this.warning,
    this.destructive = true,
  });

  final String title;
  final String text;

  /// Shown as a warning banner, like pending balances.
  final String? warning;
  final String confirmLabel;
  final String busyLabel;
  final Future<void> Function() onConfirm;

  /// Red confirm button; otherwise the green primary one.
  final bool destructive;

  @override
  State<MemberActionDialog> createState() => _MemberActionDialogState();
}

class _MemberActionDialogState extends State<MemberActionDialog> {
  bool _busy = false;
  GroupFailure? _failure;

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await widget.onConfirm();
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

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final warning = widget.warning;
    final failure = _failure;
    return FbuDialog(
      semanticsLabel: widget.title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DialogHeading(title: widget.title, subtitle: widget.text),
          if (warning != null) ...[
            SizedBox(height: tokens.space2),
            AuthBanner(message: warning, kind: AuthBannerKind.warning),
          ],
          if (failure != null) ...[
            SizedBox(height: tokens.space2),
            AuthBanner(message: HomeStrings.failure(failure)),
          ],
          SizedBox(height: tokens.space3),
          if (widget.destructive)
            FbuPillButton(
              onPressed: _confirm,
              isLoading: _busy,
              loadingSemanticsLabel: widget.busyLabel,
              colors: FbuPillButtonColors.destructive(tokens),
              child: Text(widget.confirmLabel),
            )
          else
            FbuPrimaryButton(
              onPressed: _confirm,
              isLoading: _busy,
              loadingSemanticsLabel: widget.busyLabel,
              child: Text(widget.confirmLabel),
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
