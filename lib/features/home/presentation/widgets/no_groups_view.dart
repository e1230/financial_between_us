import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../dialogs/create_group_dialog.dart';
import '../dialogs/join_group_dialog.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';
import 'translucent_action_card.dart';

/// Home content without active groups: create or join one.
class NoGroupsView extends StatelessWidget {
  const NoGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: HomeMetrics.emptyContentExtraGap),
        Semantics(
          header: true,
          child: Text(HomeStrings.emptyTitle, style: styles.emptyTitle),
        ),
        SizedBox(height: tokens.space1),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HomeMetrics.emptyTextMaxWidth,
            ),
            child: Text(HomeStrings.emptyText, style: styles.lead),
          ),
        ),
        const SizedBox(height: HomeMetrics.emptyCardsGap),
        TranslucentActionCard(
          icon: Icons.person_add_alt_outlined,
          title: HomeStrings.createCardTitle,
          description: HomeStrings.createCardText,
          onTap: () => showCreateGroupDialog(context),
        ),
        SizedBox(height: tokens.space2),
        TranslucentActionCard(
          icon: Icons.login,
          title: HomeStrings.joinCardTitle,
          description: HomeStrings.joinCardText,
          onTap: () => showJoinGroupDialog(context),
        ),
        const SizedBox(height: HomeMetrics.emptyNoteGap),
      ],
    );
  }
}
