import 'dart:ui' show lerpDouble;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../groups/data/groups_providers.dart';
import '../../groups/presentation/widgets/groups_message.dart';
import '../../home/presentation/widgets/arc_background.dart';
import '../data/balances_providers.dart';
import '../domain/balances_overview.dart';
import '../domain/balances_scope.dart';
import 'balances_metrics.dart';
import 'balances_strings.dart';
import 'balances_text_styles.dart';
import 'widgets/all_clear_view.dart';
import 'widgets/balances_skeleton.dart';
import 'widgets/balances_tabs.dart';
import 'widgets/person_section.dart';
import 'widgets/settled_section.dart';
import 'widgets/summary_card.dart';

/// "Saldos": the net balance of the active group (or of every group) and
/// the people who owe the user, whom they owe and who is even.
///
/// The Home arc stays still behind everything. When the list scrolls, the
/// title shrinks from 28 to 20 and stays pinned with the tabs; the content
/// passes under them with a clean cut.
class BalancesScreen extends ConsumerStatefulWidget {
  const BalancesScreen({super.key});

  @override
  ConsumerState<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends ConsumerState<BalancesScreen> {
  final ScrollController _scroll = ScrollController();

  /// Last overview shown, kept while another tab loads so the summary
  /// counts from it instead of blinking.
  BalancesOverview? _last;

  /// Height the title row loses when collapsed.
  static const double _titleCollapsedHeight = 32;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _open(BalancesScope scope, PersonBalance person) =>
      context.push(AppRoutes.personBalanceFor(person.uid, scope.param));

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final active = ref.watch(activeGroupProvider).value;
    final tab = ref.watch(selectedBalancesTabProvider);
    final scope = tab == BalancesTab.group && active != null
        ? BalancesScope.group(active.id)
        : const BalancesScope.all();
    final groups = ref.watch(myGroupsProvider).value ?? const [];
    final groupNames = {for (final g in groups) g.id: g.name};
    final overviewAsync = ref.watch(balancesOverviewProvider(scope));
    final overview =
        overviewAsync.value ?? (overviewAsync.isLoading ? _last : null);
    if (overviewAsync.hasValue) _last = overviewAsync.value;

    final titleTop = padding.top + BalancesMetrics.headerTopGap;
    const titleExpanded = BalancesMetrics.headerHeight;
    final headerMax =
        titleTop +
        titleExpanded +
        tokens.space2 +
        BalancesMetrics.tabsHeight +
        BalancesMetrics.tabsBottomGap;
    final collapseBy =
        titleExpanded + tokens.space2 - _titleCollapsedHeight - tokens.space1;
    final headerMin = headerMax - collapseBy;

    final Widget body;
    if (overview != null) {
      final scopeName = scope.isAll
          ? BalancesStrings.groupsScope(overview.groupCount)
          : active?.name ?? '';
      body = _Content(
        overview: overview,
        scope: scope,
        scopeName: scopeName,
        groupNames: groupNames,
        onOpen: (person) => _open(scope, person),
      );
    } else if (overviewAsync.hasError) {
      body = GroupsMessage(
        text: BalancesStrings.loadError,
        action: BalancesStrings.retry,
        onAction: () {
          ref.invalidate(groupMovementsProvider);
          ref.invalidate(myGroupsProvider);
        },
      );
    } else {
      body = const BalancesSkeleton();
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ArcBackground()),
          Positioned(
            top: headerMin,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(
                  tokens.space2,
                  collapseBy,
                  tokens.space2,
                  padding.bottom + tokens.space3,
                ),
                child: AnimatedSwitcher(
                  duration: reduceMotion
                      ? BalancesMetrics.reducedFade
                      : BalancesMetrics.crossfade,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(
                      overview == null
                          ? overviewAsync.hasError
                                ? 'error'
                                : 'loading'
                          : 'content',
                    ),
                    child: body,
                  ),
                ),
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
                final offset = _scroll.hasClients ? _scroll.offset : 0.0;
                final t = (offset / collapseBy).clamp(0.0, 1.0);
                return Padding(
                  padding: EdgeInsets.only(top: titleTop),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: lerpDouble(
                          titleExpanded,
                          _titleCollapsedHeight,
                          t,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: BalancesMetrics.titleLeft,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Semantics(
                              header: true,
                              child: Text(
                                BalancesStrings.title,
                                maxLines: 1,
                                style: TextStyle.lerp(
                                  styles.title,
                                  styles.titleCollapsed,
                                  t,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: lerpDouble(tokens.space2, tokens.space1, t),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space2,
                        ),
                        child: BalancesTabs(
                          groupName: active?.name,
                          selected: scope.isAll
                              ? BalancesTab.all
                              : BalancesTab.group,
                          onSelect: (tab) => ref
                              .read(selectedBalancesTabProvider.notifier)
                              .select(tab),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.overview,
    required this.scope,
    required this.scopeName,
    required this.groupNames,
    required this.onOpen,
  });

  final BalancesOverview overview;
  final BalancesScope scope;
  final String scopeName;
  final Map<String, String> groupNames;
  final ValueChanged<PersonBalance> onOpen;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final o = overview;
    final settled = o.settled.isEmpty
        ? null
        : SettledSection(
            people: o.settled,
            scopeName: scopeName,
            isAllGroups: scope.isAll,
            groupNames: groupNames,
            onOpen: onOpen,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(overview: o, scopeName: scopeName),
        const SizedBox(height: BalancesMetrics.listTopGap),
        // The lists cross-fade when the tab changes; the summary above
        // counts from its previous value instead.
        AnimatedSwitcher(
          duration: reduceMotion
              ? BalancesMetrics.reducedFade
              : BalancesMetrics.crossfade,
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, ?current],
          ),
          child: Column(
            key: ValueKey(scope),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (o.isAllClear) AllClearView(scopeName: scopeName),
              if (o.owedToMe.isNotEmpty)
                PersonSection(
                  label: BalancesStrings.owedSection(o.owedToMe.length),
                  people: o.owedToMe,
                  isAllGroups: scope.isAll,
                  groupNames: groupNames,
                  onOpen: onOpen,
                ),
              if (o.iOwe.isNotEmpty) ...[
                if (o.owedToMe.isNotEmpty)
                  const SizedBox(height: BalancesMetrics.sectionGap),
                PersonSection(
                  label: BalancesStrings.oweSection(o.iOwe.length),
                  people: o.iOwe,
                  isAllGroups: scope.isAll,
                  groupNames: groupNames,
                  onOpen: onOpen,
                  firstIndex: o.owedToMe.length,
                ),
              ],
              if (settled != null) ...[
                if (!o.isAllClear)
                  const SizedBox(height: BalancesMetrics.sectionGap),
                settled,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
