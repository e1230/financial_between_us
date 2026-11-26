import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/fbu_primary_button.dart';
import '../../../core/widgets/fbu_secondary_button.dart';
import '../../auth/data/auth_providers.dart';
import '../../home/presentation/dialogs/create_group_dialog.dart';
import '../../home/presentation/dialogs/join_group_dialog.dart';
import '../../home/presentation/home_metrics.dart';
import '../../home/presentation/home_strings.dart';
import '../../home/presentation/home_text_styles.dart';
import '../data/groups_providers.dart';
import '../domain/group.dart';
import 'dialogs/leave_group_dialog.dart';
import 'groups_metrics.dart';
import 'groups_strings.dart';
import 'widgets/group_card.dart';
import 'widgets/groups_message.dart';
import 'widgets/groups_skeleton.dart';

/// "Grupos", opened from the avatar menu: the user's groups (active and
/// pending), creating one, joining with a code and leaving.
class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final uid = ref.watch(authStateChangesProvider).value?.uid;
    final groupsAsync = ref.watch(myGroupsProvider);
    final shownInHome = ref.watch(activeGroupProvider).value?.id;

    final Widget list;
    if (groupsAsync.hasValue && uid != null) {
      list = _GroupList(
        groups: groupsAsync.requireValue,
        uid: uid,
        shownInHomeId: shownInHome,
      );
    } else if (groupsAsync.hasError && !groupsAsync.isLoading) {
      list = GroupsMessage(
        text: GroupsStrings.loadError,
        action: HomeStrings.retry,
        onAction: () => ref.invalidate(myGroupsProvider),
      );
    } else {
      list = const GroupsSkeleton();
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: padding.top + GroupsMetrics.backTop,
          bottom: padding.bottom + tokens.space3,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: GroupsMetrics.backInset,
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: GroupsStrings.back,
                  icon: Icon(
                    Icons.arrow_back,
                    size: GroupsMetrics.backIconSize,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HomeMetrics.contentPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: tokens.space1),
                  Semantics(
                    header: true,
                    child: Text(GroupsStrings.title, style: styles.greeting),
                  ),
                  SizedBox(height: tokens.space1),
                  Text(GroupsStrings.subtitle, style: styles.lead),
                  SizedBox(height: tokens.space3),
                  FbuPrimaryButton(
                    onPressed: () => showCreateGroupDialog(context),
                    child: const Text(HomeStrings.createGroup),
                  ),
                  SizedBox(height: tokens.space1),
                  FbuSecondaryButton(
                    onPressed: () => showJoinGroupDialog(context),
                    child: const Text(HomeStrings.joinWithCode),
                  ),
                  SizedBox(height: tokens.space4),
                  Semantics(
                    header: true,
                    child: Text(HomeStrings.yourGroups, style: styles.overline),
                  ),
                  SizedBox(height: tokens.space2),
                  list,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupList extends StatelessWidget {
  const _GroupList({
    required this.groups,
    required this.uid,
    required this.shownInHomeId,
  });

  final List<Group> groups;
  final String uid;
  final String? shownInHomeId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (groups.isEmpty) {
      return Text(
        GroupsStrings.empty,
        style: HomeTextStyles.of(context).cardText,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, group) in groups.indexed)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.space1),
            child: GroupCard(
              key: ValueKey(group.id),
              group: group,
              index: index,
              uid: uid,
              isShownInHome: group.id == shownInHomeId,
              onOpen: () => context.push(AppRoutes.groupDetailFor(group.id)),
              onLeave: () =>
                  showLeaveGroupDialog(context, group: group, uid: uid),
            ),
          ),
      ],
    );
  }
}
