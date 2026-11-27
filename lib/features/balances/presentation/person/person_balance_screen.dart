import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/platform/share_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_toast.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../groups/data/groups_providers.dart';
import '../../../groups/domain/group.dart';
import '../../../groups/presentation/widgets/groups_message.dart';
import '../../../home/presentation/widgets/arc_background.dart';
import '../../../payment_accounts/data/payment_accounts_providers.dart';
import '../../../payment_accounts/domain/payment_account.dart';
import '../../../payment_accounts/domain/payment_account_rules.dart';
import '../../../payment_accounts/presentation/payment_accounts_strings.dart';
import '../../../profile/data/profile_providers.dart';
import '../../../profile/domain/user_profile.dart';
import '../../data/balances_providers.dart';
import '../../domain/balances_scope.dart';
import '../../domain/ledger_movement.dart';
import '../../domain/pair_ledger.dart';
import '../../domain/person_ledger.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../sheets/movement_detail_sheet.dart';
import '../sheets/register_debt_sheet.dart';
import '../sheets/register_payment_sheet.dart';
import '../widgets/balances_skeleton.dart';
import '../widgets/person_avatar.dart';
import '../widgets/section_label.dart';
import '../widgets/staggered_entry.dart';
import 'action_bar.dart';
import 'balance_card.dart';
import 'collapsed_bar.dart';
import 'history_entry.dart';
import 'history_section.dart';
import 'pending_card.dart';
import 'person_accounts_card.dart';

/// The balance with one person, full screen over the shell: their header,
/// the balance ("Recordarle" when they owe), the pending items, their
/// accounts (when the user owes them), the history and the actions.
///
/// [scopeParam] is a group id or `all` (see [BalancesScope.fromParam]).
class PersonBalanceScreen extends ConsumerStatefulWidget {
  const PersonBalanceScreen({super.key, required this.uid, this.scopeParam});

  final String uid;
  final String? scopeParam;

  @override
  ConsumerState<PersonBalanceScreen> createState() =>
      _PersonBalanceScreenState();
}

class _PersonBalanceScreenState extends ConsumerState<PersonBalanceScreen> {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _historyKey = GlobalKey();
  bool _expanded = false;
  HistoryFilter _filter = HistoryFilter.all;
  Set<String> _highlighted = const {};
  Timer? _highlightTimer;

  late final BalancesScope _scope = BalancesScope.fromParam(widget.scopeParam);

  /// Where the header starts below the status bar.
  static const double _headerTop =
      BalancesMetrics.personHeaderTop - BalancesMetrics.headerTopGap * 3;

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  String get _me => ref.read(authStateChangesProvider).value?.uid ?? '';

  void _toast(String message) {
    FbuToast.show(context, message, position: FbuToastPosition.aboveActions);
  }

  void _highlight(Iterable<String> ids) {
    _highlightTimer?.cancel();
    setState(() => _highlighted = ids.toSet());
    _highlightTimer = Timer(BalancesMetrics.highlight, () {
      if (mounted) setState(() => _highlighted = const {});
    });
  }

  /// Name of the scope for texts: the group, or "2 grupos".
  String _scopeName(PersonLedger data, Map<String, Group> groups) {
    final ids = _scope.isAll ? data.groupIds : [?_scope.groupId];
    if (ids.length == 1) return groups[ids.single]?.name ?? '';
    return BalancesStrings.groupsScope(ids.length);
  }

  Future<void> _remind(UserProfile? other, int amount, String scopeName) async {
    // Without accounts (or while they load) the text just omits them.
    final accounts =
        ref.read(myPaymentAccountsProvider).value ?? const <PaymentAccount>[];
    final text = BalancesStrings.reminder(
      firstName: PersonNames.first(other),
      amount: amount,
      scope: scopeName,
      accounts: [
        for (final a in accounts)
          if (a.hasReference)
            '${a.type.label} ${PaymentAccountRules.displayReference(a)}',
      ],
    );
    await ref.read(shareServiceProvider).shareText(text);
  }

  Future<void> _registerPayment(PairLedger ledger, UserProfile? other) async {
    final me = _me;
    final theyPayMe = ledger.balance > 0;
    final result = await showRegisterPaymentSheet(
      context,
      me: me,
      otherUid: widget.uid,
      otherFirstName: PersonNames.first(other),
      theyPayMe: theyPayMe,
      pendings: ledger.pendingsOwedBy(theyPayMe ? widget.uid : me),
    );
    if (result == null || !mounted) return;
    unawaited(HapticFeedback.lightImpact());
    _toast(BalancesStrings.paymentRegistered(result.amount));
    _highlight(result.ids);
  }

  Future<void> _registerDebt(
    PersonLedger data,
    Map<String, Group> groups,
    UserProfile? other,
  ) async {
    final active = ref.read(activeGroupProvider).value?.id;
    final ids = [
      for (final id in data.groupIds)
        if (groups[id]?.isActiveMember(_me) ?? false) id,
    ];
    if (ids.isEmpty) return;
    // The active group first when it is one of them.
    ids.sort((a, b) => a == active ? -1 : (b == active ? 1 : 0));
    final id = await showRegisterDebtSheet(
      context,
      me: _me,
      otherUid: widget.uid,
      otherFullName: PersonNames.full(other),
      otherFirstName: PersonNames.first(other),
      groups: [
        for (final id in ids)
          DebtGroupOption(id: id, name: groups[id]?.name ?? ''),
      ],
    );
    if (id == null || !mounted) return;
    unawaited(HapticFeedback.lightImpact());
    _toast(BalancesStrings.debtRegistered);
    _highlight([id]);
  }

  Future<void> _openMovement(
    LedgerMovement movement,
    PairLedger ledger,
    UserProfile? other,
  ) async {
    final first = PersonNames.first(other);
    final outcome = await showMovementDetailSheet(
      context,
      movement: movement,
      me: _me,
      otherFirstName: first,
      related: {for (final m in ledger.history) m.id: m},
    );
    if (!mounted) return;
    switch (outcome) {
      case MovementSheetOutcome.rejected:
        _toast(
          movement.isPayment
              ? BalancesStrings.paymentRejected(first)
              : BalancesStrings.debtRejected(first),
        );
      case MovementSheetOutcome.deleted:
        _toast(BalancesStrings.movementDeleted);
      case null:
        break;
    }
  }

  void _seeAll() {
    setState(() => _expanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _historyKey.currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : BalancesMetrics.detailEntry,
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _footnote(UserProfile? other, Map<String, Group> groups) {
    final groupId = _scope.groupId;
    if (groupId == null) return BalancesStrings.historyStartShort;
    final members = ref.watch(groupMembersProvider(groupId)).value;
    final joinedAt = members
        ?.where((m) => m.uid == widget.uid)
        .firstOrNull
        ?.joinedAt;
    final group = groups[groupId]?.name;
    if (joinedAt == null || group == null) {
      return BalancesStrings.historyStartShort;
    }
    return BalancesStrings.historyStart(
      PersonNames.first(other),
      group,
      BalancesDates.short(joinedAt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final me = ref.watch(authStateChangesProvider).value?.uid ?? '';
    final other = ref.watch(userProfileProvider(widget.uid)).value;
    // Kept loaded for "Recordarle".
    ref.watch(myPaymentAccountsProvider);
    final groups = {
      for (final g in ref.watch(myGroupsProvider).value ?? const <Group>[])
        g.id: g,
    };
    final dataAsync = ref.watch(personLedgerProvider(_scope, widget.uid));
    final data = dataAsync.value;
    final ledger = data?.ledger;
    final first = PersonNames.first(other);
    final nickname = PersonNames.nickname(other);
    final scopeName = data == null ? '' : _scopeName(data, groups);
    final sub = [
      if (nickname.isNotEmpty) BalancesStrings.handle(nickname),
      if (scopeName.isNotEmpty) scopeName,
    ].join(' · ');
    final bottomInset = PersonActionBar.height + padding.bottom;

    final Widget body;
    if (data != null && ledger != null) {
      final related = {for (final m in ledger.history) m.id: m};
      final entries = [
        for (final m in ledger.history)
          HistoryEntry.of(
            m,
            me: me,
            otherFirst: first,
            ledger: ledger,
            related: related,
          ),
      ];
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BalanceCard(
            balance: ledger.balance,
            pendingCount: ledger.pendings.length,
            oldestPendingAt: ledger.oldestPendingAt,
            lastActivityAt: ledger.lastActivityAt,
            onRemind: () => _remind(other, ledger.balance, scopeName),
          ),
          const SizedBox(height: BalancesMetrics.sectionGap),
          SectionLabel(BalancesStrings.pendingSection(ledger.pendings.length)),
          PendingCard(
            pendings: ledger.pendings,
            me: me,
            otherFirst: first,
            onOpen: (item) => _openMovement(item.source, ledger, other),
          ),
          if (ledger.balance < 0)
            PersonAccountsCard(uid: widget.uid, firstName: first),
          const SizedBox(height: BalancesMetrics.sectionGap),
          KeyedSubtree(
            key: _historyKey,
            child: HistorySection(
              entries: entries,
              expanded: _expanded,
              filter: _filter,
              onFilter: (f) => setState(() => _filter = f),
              onSeeAll: _seeAll,
              onOpen: (e) => _openMovement(e.movement, ledger, other),
              highlighted: _highlighted,
              footnote: _footnote(other, groups),
            ),
          ),
        ],
      );
    } else if (dataAsync.hasError) {
      body = GroupsMessage(
        text: BalancesStrings.loadError,
        action: BalancesStrings.retry,
        onAction: () => ref.invalidate(groupMovementsProvider),
      );
    } else {
      body = const BalancesSkeleton();
    }

    final header = Row(
      children: [
        PersonAvatar(
          profile: other,
          size: BalancesMetrics.personAvatar,
          heroTag: personAvatarTag(widget.uid),
        ),
        const SizedBox(width: BalancesMetrics.personHeaderGap),
        Expanded(
          child: StaggeredEntry(
            index: 0,
            delay: BalancesMetrics.detailEntryDelay,
            duration: BalancesMetrics.detailEntry,
            offset: BalancesMetrics.detailEntryOffset,
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      PersonNames.full(other),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: styles.personName,
                    ),
                  ),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.personSub,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ArcBackground()),
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(
                tokens.space2,
                padding.top + _headerTop,
                tokens.space2,
                bottomInset + tokens.space2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: tokens.space1),
                    child: header,
                  ),
                  SizedBox(height: tokens.space2),
                  StaggeredEntry(
                    index: 0,
                    delay: BalancesMetrics.detailEntryDelay,
                    duration: BalancesMetrics.detailEntry,
                    offset: BalancesMetrics.detailEntryOffset,
                    child: AnimatedSwitcher(
                      duration: reduceMotion
                          ? BalancesMetrics.reducedFade
                          : BalancesMetrics.crossfade,
                      child: KeyedSubtree(
                        key: ValueKey(
                          data != null
                              ? 'content'
                              : dataAsync.hasError
                              ? 'error'
                              : 'loading',
                        ),
                        child: body,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _scroll,
              builder: (context, _) {
                final collapsed =
                    _scroll.hasClients &&
                    _scroll.offset > BalancesMetrics.collapseAfter;
                return PersonCollapsedBar(
                  visible: collapsed,
                  profile: other,
                  balance: ledger?.balance ?? 0,
                );
              },
            ),
          ),
          Positioned(
            top: padding.top + BalancesMetrics.headerTopGap,
            left: BalancesMetrics.backLeft,
            child: IconButton(
              tooltip: BalancesStrings.back,
              constraints: const BoxConstraints.tightFor(
                width: BalancesMetrics.backSize,
                height: BalancesMetrics.backSize,
              ),
              color: tokens.textPrimary,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          if (ledger != null && data != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PersonActionBar(
                isSettled: ledger.balance == 0,
                onDebt: () => _registerDebt(data, groups, other),
                onPayment: () => _registerPayment(ledger, other),
              ),
            ),
        ],
      ),
    );
  }
}
