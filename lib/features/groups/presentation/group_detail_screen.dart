import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/fbu_pill_button.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/presentation/widgets/auth_banner.dart';
import '../../balances/data/balances_providers.dart';
import '../../balances/domain/pair_balances.dart';
import '../../home/presentation/home_metrics.dart';
import '../../home/presentation/home_strings.dart';
import '../../home/presentation/home_text_styles.dart';
import '../data/groups_providers.dart';
import '../domain/group.dart';
import '../domain/group_failure.dart';
import '../domain/group_member.dart';
import 'dialogs/leave_group_dialog.dart';
import 'dialogs/member_action_dialog.dart';
import 'groups_metrics.dart';
import 'groups_strings.dart';
import 'widgets/group_info_card.dart';
import 'widgets/groups_message.dart';
import 'widgets/groups_skeleton.dart';
import 'widgets/member_tile.dart';
import 'widgets/pending_member_tile.dart';

/// Detail of a group, opened from "Grupos": a summary, the members (role,
/// since when, and the user's balance with each one) and the pending
/// requests. The admin can remove members and approve or reject requests.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final uid = ref.watch(authStateChangesProvider).value?.uid;
    final groupAsync = ref.watch(groupByIdProvider(groupId));
    final group = groupAsync.value;

    final Widget body;
    if (group != null && uid != null) {
      body = _GroupContent(group: group, uid: uid);
    } else if (groupAsync.hasError && !groupAsync.isLoading) {
      body = GroupsMessage(
        text: GroupsStrings.loadError,
        action: HomeStrings.retry,
        onAction: () => ref.invalidate(myGroupsProvider),
      );
    } else if (groupAsync.hasValue) {
      body = GroupsMessage(
        text: GroupsStrings.notMember,
        action: GroupsStrings.back,
        onAction: () => Navigator.of(context).maybePop(),
      );
    } else {
      body = const GroupsSkeleton();
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
                  if (group != null) ...[
                    SizedBox(height: tokens.space1),
                    Semantics(
                      header: true,
                      child: Text(group.name, style: styles.greeting),
                    ),
                    SizedBox(height: tokens.space3),
                  ],
                  body,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Everything below the title, once the group is known.
class _GroupContent extends ConsumerStatefulWidget {
  const _GroupContent({required this.group, required this.uid});

  final Group group;
  final String uid;

  @override
  ConsumerState<_GroupContent> createState() => _GroupContentState();
}

class _GroupContentState extends ConsumerState<_GroupContent> {
  /// Request being approved.
  String? _approving;

  /// Failure of the last approval.
  GroupFailure? _failure;

  Group get _group => widget.group;
  String get _uid => widget.uid;

  Future<void> _approve(String memberUid) async {
    setState(() {
      _approving = memberUid;
      _failure = null;
    });
    try {
      await ref
          .read(groupsRepositoryProvider)
          .approveMember(
            groupId: _group.id,
            adminUid: _uid,
            memberUid: memberUid,
          );
    } on GroupFailure catch (failure) {
      if (mounted) setState(() => _failure = failure);
    } finally {
      if (mounted) setState(() => _approving = null);
    }
  }

  Future<void> _reject(String memberUid, String name) =>
      showRejectRequestDialog(
        context,
        name: name,
        onConfirm: () => ref
            .read(groupsRepositoryProvider)
            .rejectMember(
              groupId: _group.id,
              adminUid: _uid,
              memberUid: memberUid,
            ),
      );

  Future<void> _remove(String memberUid, String name) {
    final debts = ref.read(groupDebtsProvider(_group.id)).value ?? const [];
    return showRemoveMemberDialog(
      context,
      name: name,
      hasPendingBalance: netBalance(memberUid, debts) != 0,
      onConfirm: () => ref
          .read(groupsRepositoryProvider)
          .removeMember(
            groupId: _group.id,
            adminUid: _uid,
            memberUid: memberUid,
          ),
    );
  }

  Future<void> _leave() async {
    final left = await showLeaveGroupDialog(context, group: _group, uid: _uid);
    if (left && mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final isAdmin = _group.isAdmin(_uid);
    final groups = ref.watch(myGroupsProvider).value ?? const <Group>[];
    final index = groups.indexWhere((g) => g.id == _group.id);
    final shownInHome = ref.watch(activeGroupProvider).value?.id;
    final membersAsync = ref.watch(groupMembersProvider(_group.id));
    final balances = ref.watch(myBalancesProvider(_group.id)).value;

    Widget section(String title) => Padding(
      padding: EdgeInsets.only(top: tokens.space4, bottom: tokens.space1),
      child: Semantics(
        header: true,
        child: Text(title, style: styles.overline),
      ),
    );

    final List<Widget> members;
    if (membersAsync.hasValue) {
      final all = membersAsync.requireValue;
      final active = all.where((m) => m.status == MemberStatus.active);
      final pending = all.where((m) => m.status == MemberStatus.pending);
      members = [
        section(GroupsStrings.membersTitle),
        for (final member in active)
          MemberTile(
            key: ValueKey(member.uid),
            member: member,
            isMe: member.uid == _uid,
            balance: member.uid == _uid || balances == null
                ? null
                : balances[member.uid] ?? 0,
            onRemove: isAdmin && member.uid != _uid
                ? (name) => _remove(member.uid, name)
                : null,
          ),
        if (pending.isNotEmpty) ...[
          section(GroupsStrings.pendingTitle),
          if (_failure case final failure?) ...[
            AuthBanner(message: HomeStrings.failure(failure)),
            SizedBox(height: tokens.space1),
          ],
          for (final member in pending)
            PendingMemberTile(
              key: ValueKey(member.uid),
              member: member,
              busy: _approving == member.uid,
              onApprove: isAdmin ? (_) => _approve(member.uid) : null,
              onReject: isAdmin ? (name) => _reject(member.uid, name) : null,
            ),
        ],
      ];
    } else if (membersAsync.hasError && !membersAsync.isLoading) {
      members = [
        section(GroupsStrings.membersTitle),
        GroupsMessage(
          text: GroupsStrings.membersError,
          action: HomeStrings.retry,
          onAction: () => ref.invalidate(groupMembersProvider(_group.id)),
        ),
      ];
    } else {
      members = [
        section(GroupsStrings.membersTitle),
        Semantics(
          label: GroupsStrings.loadingMembers,
          child: const ExcludeSemantics(child: GroupsSkeleton()),
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GroupInfoCard(
          group: _group,
          index: index < 0 ? 0 : index,
          uid: _uid,
          isShownInHome: shownInHome == _group.id,
          onShowInHome: () =>
              ref.read(selectedGroupIdProvider.notifier).select(_group.id),
        ),
        ...members,
        SizedBox(height: tokens.space4),
        FbuPillButton(
          onPressed: _leave,
          colors: FbuPillButtonColors.destructive(tokens),
          child: const Text(GroupsStrings.leave),
        ),
      ],
    );
  }
}
