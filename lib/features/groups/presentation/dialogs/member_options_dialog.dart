import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_dialog.dart';
import '../../../../core/widgets/fbu_pill_button.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../../../home/presentation/dialogs/dialog_parts.dart';
import '../groups_strings.dart';

/// What an admin can do with a member (see `Group.canPromote`,
/// `Group.canDemote` and `Group.canRemove`).
enum MemberOption { promote, demote, remove }

/// Lets an admin pick what to do with [name]: one button per option of
/// [options], in their order. Completes with the chosen one, or `null`
/// when cancelled.
Future<MemberOption?> showMemberOptionsDialog(
  BuildContext context, {
  required String name,
  required List<MemberOption> options,
}) => showFbuDialog<MemberOption>(
  context: context,
  builder: (_) => MemberOptionsDialog(name: name, options: options),
);

class MemberOptionsDialog extends StatelessWidget {
  const MemberOptionsDialog({
    super.key,
    required this.name,
    required this.options,
  });

  final String name;
  final List<MemberOption> options;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final navigator = Navigator.of(context);

    Widget button(MemberOption option) {
      void choose() => navigator.pop(option);
      return switch (option) {
        MemberOption.promote => FbuSecondaryButton(
          onPressed: choose,
          child: const Text(GroupsStrings.promote),
        ),
        MemberOption.demote => FbuSecondaryButton(
          onPressed: choose,
          child: const Text(GroupsStrings.demote),
        ),
        MemberOption.remove => FbuPillButton(
          onPressed: choose,
          colors: FbuPillButtonColors.destructive(tokens),
          child: const Text(GroupsStrings.removeMember),
        ),
      };
    }

    return FbuDialog(
      semanticsLabel: GroupsStrings.memberOptions(name),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DialogHeading(title: name, subtitle: GroupsStrings.memberOptionsText),
          for (final option in options) ...[
            SizedBox(height: tokens.space2),
            button(option),
          ],
          SizedBox(height: tokens.space1),
          DialogCancelButton(onPressed: navigator.pop),
        ],
      ),
    );
  }
}
