import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/pill_choice.dart';
import '../widgets/section_label.dart';
import 'history_entry.dart';
import 'history_row.dart';

/// "HISTORIAL". The short view shows the latest [shortCount] movements and
/// "Ver todo"; the full one adds the filters (Todo, Eventos, Directos,
/// Pagos), groups the rows by month and grows as the user scrolls (the
/// screen loads the next page). It ends with a spinner while a page loads,
/// "Reintentar" if it failed, or [footnote] once everything is loaded.
class HistorySection extends StatelessWidget {
  const HistorySection({
    super.key,
    required this.entries,
    required this.expanded,
    required this.filter,
    required this.onFilter,
    required this.onSeeAll,
    required this.onOpen,
    required this.highlighted,
    required this.footnote,
    required this.onRetry,
    this.isLoading = false,
    this.hasError = false,
    this.hasMore = false,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  /// Newest first.
  final List<HistoryEntry> entries;
  final bool expanded;
  final HistoryFilter filter;
  final ValueChanged<HistoryFilter> onFilter;
  final VoidCallback onSeeAll;
  final ValueChanged<HistoryEntry> onOpen;

  /// Ids of movements just registered (highlighted for 2 s).
  final Set<String> highlighted;
  final String footnote;
  final VoidCallback onRetry;

  /// The first page is loading.
  final bool isLoading;

  /// The first page failed.
  final bool hasError;

  /// There may be older movements to load.
  final bool hasMore;
  final bool loadingMore;
  final bool loadMoreFailed;

  static const int shortCount = 3;
  static const double _spinnerSize = 20;
  static const double _spinnerStroke = 2;

  Widget _spinner(BuildContext context, String label) {
    final tokens = context.tokens;
    return Semantics(
      label: label,
      liveRegion: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space2),
        child: Center(
          child: SizedBox.square(
            dimension: _spinnerSize,
            child: CircularProgressIndicator(
              strokeWidth: _spinnerStroke,
              color: tokens.accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _retry(BuildContext context, String message) {
    final styles = BalancesTextStyles.of(context);
    return Padding(
      padding: EdgeInsets.only(top: context.tokens.space1),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(message, style: styles.body),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, BalancesMetrics.touchTarget),
            ),
            child: Text(BalancesStrings.retry, style: styles.link),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);

    if (!expanded) {
      final shown = entries.take(shortCount).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(
            BalancesStrings.history,
            trailing: entries.length > shortCount || hasMore
                ? TextButton(
                    onPressed: onSeeAll,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, BalancesMetrics.touchTarget),
                    ),
                    child: Text(BalancesStrings.seeAll, style: styles.link),
                  )
                : null,
          ),
          if (isLoading)
            _spinner(context, BalancesStrings.loadingHistory)
          else if (hasError)
            _retry(context, BalancesStrings.historyError)
          else if (shown.isEmpty)
            Text(BalancesStrings.noHistory, style: styles.body)
          else
            ..._rows(context, shown),
        ],
      );
    }

    final filtered = [
      for (final e in entries)
        if (filter.accepts(e.movement)) e,
    ];
    final children = <Widget>[];
    String? month;
    for (final e in filtered) {
      final m = BalancesDates.month(e.movement.date);
      if (m != month) {
        month = m;
        children.add(
          Padding(
            padding: EdgeInsets.only(
              top: tokens.space2,
              left: BalancesMetrics.sectionLabelPaddingH,
            ),
            child: Semantics(
              header: true,
              child: Text(m, style: styles.sectionLabel),
            ),
          ),
        );
      }
      children.addAll(_rows(context, [e]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(BalancesStrings.history),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final f in HistoryFilter.values) ...[
                if (f != HistoryFilter.values.first)
                  SizedBox(width: tokens.space1),
                PillChoice(
                  label: f.label,
                  selected: f == filter,
                  height: BalancesMetrics.filterHeight,
                  onTap: () => onFilter(f),
                ),
              ],
            ],
          ),
        ),
        if (filtered.isEmpty && !hasMore && !loadingMore)
          Padding(
            padding: EdgeInsets.only(top: tokens.space2),
            child: Text(BalancesStrings.noHistory, style: styles.body),
          ),
        ...children,
        if (loadingMore)
          _spinner(context, BalancesStrings.loadingMore)
        else if (loadMoreFailed)
          _retry(context, BalancesStrings.loadMoreError)
        else if (!hasMore) ...[
          SizedBox(height: tokens.space3),
          Text(footnote, textAlign: TextAlign.center, style: styles.footnote),
        ],
      ],
    );
  }

  List<Widget> _rows(BuildContext context, List<HistoryEntry> shown) {
    final tokens = context.tokens;
    return [
      for (var i = 0; i < shown.length; i++) ...[
        if (i > 0)
          Divider(
            height: 1,
            thickness: 1,
            indent: BalancesMetrics.dividerInset - BalancesMetrics.rowPaddingH,
            color: tokens.textPrimary.withValues(
              alpha: BalancesMetrics.historyDividerOpacity,
            ),
          ),
        HistoryRow(
          key: ValueKey(shown[i].movement.id),
          entry: shown[i],
          highlighted: highlighted.contains(shown[i].movement.id),
          onTap: () => onOpen(shown[i]),
        ),
      ],
    ];
  }
}
