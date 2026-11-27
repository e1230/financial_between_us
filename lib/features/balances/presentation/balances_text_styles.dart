import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_tokens.dart';
import 'balances_metrics.dart';

/// Text styles of the balances module, derived from the app [TextTheme]:
/// Satoshi Bold for titles and Inter (tabular figures) for the rest. Screens
/// at least [AppBreakpoints.wide] wide scale everything about 7 %.
@immutable
class BalancesTextStyles {
  const BalancesTextStyles._({
    required this.title,
    required this.titleCollapsed,
    required this.tab,
    required this.label,
    required this.net,
    required this.legendAmount,
    required this.caption,
    required this.sectionLabel,
    required this.rowTitle,
    required this.rowDetail,
    required this.rowAmount,
    required this.emptyTitle,
    required this.body,
    required this.personName,
    required this.personSub,
    required this.balanceAmount,
    required this.collapsedName,
    required this.chip,
    required this.button,
    required this.link,
    required this.sheetTitle,
    required this.sheetSubtitle,
    required this.amountInput,
    required this.footnote,
  });

  factory BalancesTextStyles.of(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context).textTheme;
    final scale = MediaQuery.sizeOf(context).width >= AppBreakpoints.wide
        ? BalancesMetrics.wideTypeScale
        : 1.0;
    final heading = theme.headlineLarge!.copyWith(color: t.textPrimary);
    final body = theme.bodyMedium!.copyWith(color: t.textPrimary);

    TextStyle head(double size, double lineHeight, {double spacing = 0}) =>
        heading.copyWith(
          fontSize: (size * scale).roundToDouble(),
          height: lineHeight / size,
          letterSpacing: spacing * size * scale,
        );
    TextStyle text(
      double size,
      double lineHeight, {
      FontWeight weight = FontWeight.w400,
      Color? color,
      double spacing = 0,
    }) => body.copyWith(
      fontSize: (size * scale).roundToDouble(),
      height: lineHeight / size,
      fontWeight: weight,
      color: color ?? t.textPrimary,
      letterSpacing: spacing * size * scale,
    );

    return BalancesTextStyles._(
      title: head(
        BalancesMetrics.titleSize,
        BalancesMetrics.titleLineHeight,
        spacing: BalancesMetrics.titleLetterSpacing,
      ),
      titleCollapsed: head(
        BalancesMetrics.titleCollapsedSize,
        BalancesMetrics.titleCollapsedLineHeight,
      ),
      tab: text(
        BalancesMetrics.tabTextSize,
        BalancesMetrics.tabTextLineHeight,
        weight: FontWeight.w500,
      ),
      label: text(
        BalancesMetrics.rowDetailSize,
        BalancesMetrics.rowDetailLineHeight,
        color: t.textSecondary,
      ),
      net: text(
        BalancesMetrics.netSize,
        BalancesMetrics.netLineHeight,
        weight: FontWeight.w600,
      ),
      legendAmount: text(
        BalancesMetrics.legendAmountSize,
        BalancesMetrics.legendAmountLineHeight,
        weight: FontWeight.w600,
      ),
      caption: text(
        BalancesMetrics.labelSize,
        BalancesMetrics.labelLineHeight,
        color: t.textSecondary,
      ),
      sectionLabel: text(
        BalancesMetrics.labelSize,
        BalancesMetrics.labelLineHeight,
        weight: FontWeight.w500,
        color: t.textSecondary,
        spacing: BalancesMetrics.labelLetterSpacing,
      ),
      rowTitle: text(
        BalancesMetrics.rowTitleSize,
        BalancesMetrics.rowTitleLineHeight,
        weight: FontWeight.w500,
      ),
      rowDetail: text(
        BalancesMetrics.rowDetailSize,
        BalancesMetrics.rowDetailLineHeight,
        color: t.textSecondary,
      ),
      rowAmount: text(
        BalancesMetrics.rowTitleSize,
        BalancesMetrics.rowTitleLineHeight,
        weight: FontWeight.w600,
      ),
      emptyTitle: head(
        BalancesMetrics.allClearTitleSize,
        BalancesMetrics.allClearTitleLineHeight,
      ),
      body: text(
        BalancesMetrics.rowDetailSize,
        BalancesMetrics.rowDetailLineHeight,
        color: t.textSecondary,
      ),
      personName: head(
        BalancesMetrics.personNameSize,
        BalancesMetrics.personNameLineHeight,
      ),
      personSub: text(
        BalancesMetrics.personSubSize,
        BalancesMetrics.personSubLineHeight,
        color: t.textSecondary,
      ),
      balanceAmount: text(
        BalancesMetrics.balanceAmountSize,
        BalancesMetrics.balanceAmountLineHeight,
        weight: FontWeight.w600,
      ),
      collapsedName: head(
        BalancesMetrics.collapsedNameSize,
        BalancesMetrics.collapsedNameLineHeight,
      ),
      chip: text(
        BalancesMetrics.chipTextSize,
        BalancesMetrics.chipTextLineHeight,
        weight: FontWeight.w500,
      ),
      button: text(
        BalancesMetrics.rowTitleSize,
        BalancesMetrics.rowTitleLineHeight,
        weight: FontWeight.w600,
      ),
      link: text(
        BalancesMetrics.rowTitleSize,
        BalancesMetrics.rowTitleLineHeight,
        weight: FontWeight.w600,
        color: t.positive,
      ),
      sheetTitle: head(
        BalancesMetrics.sheetTitleSize,
        BalancesMetrics.sheetTitleLineHeight,
      ),
      sheetSubtitle: text(
        BalancesMetrics.sheetSubtitleSize,
        BalancesMetrics.sheetSubtitleLineHeight,
        color: t.textSecondary,
      ),
      amountInput: text(
        BalancesMetrics.amountSize,
        BalancesMetrics.amountLineHeight,
        weight: FontWeight.w600,
      ),
      footnote: text(
        BalancesMetrics.labelSize,
        BalancesMetrics.labelLineHeight,
        color: t.textDisabled,
      ),
    );
  }

  /// "Saldos": Satoshi Bold 28/34.
  final TextStyle title;

  /// The title once the list scrolls: Satoshi Bold 20/26.
  final TextStyle titleCollapsed;

  /// Tabs: Inter 14/20 w500.
  final TextStyle tab;

  /// "Balance neto", "Te debe": Inter 13/18 at 60 %.
  final TextStyle label;

  /// Net balance: Inter 36/44 w600.
  final TextStyle net;

  /// Legend amounts: Inter 18/24 w600.
  final TextStyle legendAmount;

  /// Small secondary text: Inter 12/16 at 60 %.
  final TextStyle caption;

  /// "TE DEBEN · 3": Inter 12/16 w500, 0.04 em, at 60 %.
  final TextStyle sectionLabel;

  /// Row names and titles: Inter 15/20 w500.
  final TextStyle rowTitle;

  /// Row details: Inter 13/18 at 60 %.
  final TextStyle rowDetail;

  /// Row amounts: Inter 15/20 w600.
  final TextStyle rowAmount;

  /// "Todo en orden", "A paz y salvo" in lists: Satoshi 20/26.
  final TextStyle emptyTitle;

  /// Notes and footnotes: Inter 13/18 at 60 %.
  final TextStyle body;

  /// Person name: Satoshi 22/28.
  final TextStyle personName;

  /// "@santi · Low IQ Group": Inter 14/20 at 60 %.
  final TextStyle personSub;

  /// Balance of a person: Inter 32/40 w600.
  final TextStyle balanceAmount;

  /// Name in the collapsed bar: Satoshi 17/22.
  final TextStyle collapsedName;

  /// Type chips: Inter 11/16 w500.
  final TextStyle chip;

  /// Action buttons: Inter 15/20 w600.
  final TextStyle button;

  /// "Ver todo": Inter 15/20 w600 in green.
  final TextStyle link;

  /// Sheet titles: Satoshi 20/26.
  final TextStyle sheetTitle;

  /// Sheet subtitles: Inter 14/20 at 60 %.
  final TextStyle sheetSubtitle;

  /// Amount field: Inter 28/34 w600.
  final TextStyle amountInput;

  /// "Inicio del historial": Inter 12/16 at 38 %.
  final TextStyle footnote;
}
