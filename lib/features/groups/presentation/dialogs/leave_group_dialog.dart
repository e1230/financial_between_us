import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_pill_button.dart';
import '../../../auth/presentation/widgets/auth_banner.dart';
import '../../../home/presentation/dialogs/dialog_parts.dart';
import '../../../home/presentation/home_strings.dart';
import '../../data/groups_providers.dart';
import '../../domain/group.dart';
import '../../domain/group_failure.dart';
import '../../domain/leave_plan.dart';
import '../groups_strings.dart';

/// Asks before [uid] leaves [group] (or withdraws a pending request). The
/// text says what happens to the group (see [planLeave]). On confirm it
/// leaves and closes; on error it shows a banner and stays open. Completes
/// with whether the user left.
Future<bool> showLeaveGroupDialog(
  BuildContext context, {
  required Group group,
  required String uid,
}) async =>
    await showFbuDialog<bool>(
      context: context,
      builder: (_) => LeaveGroupDialog(group: group, uid: uid),
    ) ??
    false;

class LeaveGroupDialog extends ConsumerStatefulWidget {
  const LeaveGroupDialog({super.key, required this.group, required this.uid});

  final Group group;
  final String uid;

  @override
  ConsumerState<LeaveGroupDialog> createState() => _LeaveGroupDialogState();
}

class _LeaveGroupDialogState extends ConsumerState<LeaveGroupDialog> {
  bool _busy = false;
  GroupFailure? _failure;

  /// `null` when the user is no longer in the group.
  late final LeavePlan? _plan = _planOrNull();

  LeavePlan? _planOrNull() {
    try {
      return planLeave(widget.group, widget.uid);
    } on NotAMember {
      return null;
    }
  }

  Future<void> _leave() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await ref
          .read(groupsRepositoryProvider)
          .leave(groupId: widget.group.id, uid: widget.uid);
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
    final name = widget.group.name;
    final plan = _plan;
    final cancelling = plan is CancelRequest;
    final title = cancelling
        ? GroupsStrings.cancelRequestTitle(name)
        : GroupsStrings.leaveTitle(name);
    final text = switch (plan) {
      CancelRequest() => GroupsStrings.cancelRequestText,
      LeaveAndTransfer() => GroupsStrings.leaveTransferText,
      LeaveAndArchive() => GroupsStrings.leaveArchiveText,
      LeaveAsMember() || null => GroupsStrings.leaveMemberText,
    };
    final failure = _failure ?? (plan == null ? const NotAMember() : null);

    return FbuDialog(
      semanticsLabel: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DialogHeading(title: title, subtitle: text),
          if (failure != null) ...[
            SizedBox(height: tokens.space2),
            AuthBanner(message: HomeStrings.failure(failure)),
          ],
          SizedBox(height: tokens.space3),
          FbuPillButton(
            onPressed: plan == null ? null : _leave,
            isLoading: _busy,
            loadingSemanticsLabel: cancelling
                ? GroupsStrings.cancellingRequest
                : GroupsStrings.leaving,
            colors: FbuPillButtonColors.destructive(tokens),
            child: Text(
              cancelling ? GroupsStrings.cancelRequest : GroupsStrings.leave,
            ),
          ),
          SizedBox(height: tokens.space1),
          DialogCancelButton(
            onPressed: _busy ? null : Navigator.of(context).pop,
            label: cancelling ? GroupsStrings.keepRequest : HomeStrings.cancel,
          ),
        ],
      ),
    );
  }
}
