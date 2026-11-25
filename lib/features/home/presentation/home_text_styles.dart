import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import 'home_metrics.dart';

/// Text styles of the Home module, derived from the app [TextTheme]:
/// Satoshi Bold for titles and Inter (tabular figures) for the rest.
@immutable
class HomeTextStyles {
  const HomeTextStyles._({
    required this.greeting,
    required this.emptyTitle,
    required this.sectionTitle,
    required this.dialogTitle,
    required this.lead,
    required this.dialogSubtitle,
    required this.pill,
    required this.cardTitle,
    required this.cardText,
    required this.detail,
    required this.chip,
    required this.legendLabel,
    required this.legendAmount,
    required this.axis,
    required this.action,
    required this.link,
    required this.rowTitle,
    required this.rowAmount,
    required this.badge,
    required this.tab,
    required this.overline,
    required this.menuName,
    required this.menuNickname,
    required this.menuOption,
    required this.footer,
    required this.code,
    required this.small,
    required this.tooltip,
  });

  factory HomeTextStyles.of(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context).textTheme;
    final heading = theme.headlineLarge!.copyWith(color: t.textPrimary);
    final body = theme.bodyMedium!.copyWith(color: t.textPrimary);

    TextStyle title(double size, double lineHeight, {double spacing = 0}) =>
        heading.copyWith(
          fontSize: size,
          height: lineHeight / size,
          letterSpacing: spacing * size,
        );
    TextStyle text(
      double size, {
      double? lineHeight,
      FontWeight weight = FontWeight.w400,
      Color? color,
    }) => body.copyWith(
      fontSize: size,
      height: lineHeight == null ? null : lineHeight / size,
      fontWeight: weight,
      color: color ?? t.textPrimary,
    );

    return HomeTextStyles._(
      greeting: title(
        HomeMetrics.greetingSize,
        HomeMetrics.greetingLineHeight,
        spacing: HomeMetrics.titleLetterSpacing,
      ),
      emptyTitle: title(
        HomeMetrics.emptyTitleSize,
        HomeMetrics.emptyTitleLineHeight,
        spacing: HomeMetrics.titleLetterSpacing,
      ),
      sectionTitle: title(
        HomeMetrics.sectionTitleSize,
        HomeMetrics.sectionTitleLineHeight,
      ),
      dialogTitle: title(
        HomeMetrics.dialogTitleSize,
        HomeMetrics.dialogTitleLineHeight,
      ),
      lead: text(
        HomeMetrics.body16,
        lineHeight: HomeMetrics.body16LineHeight,
        color: t.textSecondary,
      ),
      dialogSubtitle: text(
        HomeMetrics.body14,
        lineHeight: HomeMetrics.body14LineHeight,
        color: t.textSecondary,
      ),
      pill: text(HomeMetrics.body15, weight: FontWeight.w500),
      cardTitle: text(
        HomeMetrics.body16,
        lineHeight: HomeMetrics.cardTitleLineHeight,
        weight: FontWeight.w500,
      ),
      cardText: text(
        HomeMetrics.body14,
        lineHeight: HomeMetrics.body14LineHeight,
        color: t.textSecondary,
      ),
      detail: text(
        HomeMetrics.body13,
        lineHeight: HomeMetrics.body13LineHeight,
        color: t.textSecondary,
      ),
      chip: text(HomeMetrics.body13, weight: FontWeight.w500),
      legendLabel: text(
        HomeMetrics.body12,
        lineHeight: HomeMetrics.body12LineHeight,
        color: t.textSecondary,
      ),
      legendAmount: text(
        HomeMetrics.amountSize,
        lineHeight: HomeMetrics.amountLineHeight,
        weight: FontWeight.w600,
      ),
      axis: text(HomeMetrics.body11, color: t.textSecondary),
      action: text(
        HomeMetrics.body13,
        lineHeight: HomeMetrics.actionLineHeight,
        weight: FontWeight.w500,
      ),
      link: text(
        HomeMetrics.body14,
        weight: FontWeight.w600,
        color: t.positive,
      ),
      rowTitle: text(
        HomeMetrics.body15,
        lineHeight: HomeMetrics.body15LineHeight,
        weight: FontWeight.w500,
      ),
      rowAmount: text(
        HomeMetrics.body15,
        lineHeight: HomeMetrics.body15LineHeight,
        weight: FontWeight.w500,
      ),
      badge: text(HomeMetrics.body11, lineHeight: HomeMetrics.body11LineHeight),
      tab: text(HomeMetrics.body12, weight: FontWeight.w500),
      overline:
          text(
            HomeMetrics.body12,
            weight: FontWeight.w500,
            color: t.textSecondary,
          ).copyWith(
            letterSpacing:
                HomeMetrics.body12 * HomeMetrics.overlineLetterSpacing,
          ),
      menuName: text(
        HomeMetrics.amountSize,
        lineHeight: HomeMetrics.menuNameLineHeight,
        weight: FontWeight.w600,
      ),
      menuNickname: text(
        HomeMetrics.body14,
        lineHeight: HomeMetrics.body14LineHeight,
        weight: FontWeight.w500,
      ),
      menuOption: text(
        HomeMetrics.body16,
        lineHeight: HomeMetrics.menuOptionLineHeight,
        weight: FontWeight.w500,
      ),
      footer: text(HomeMetrics.body12, color: t.textDisabled),
      code: text(HomeMetrics.codeSize, weight: FontWeight.w600).copyWith(
        letterSpacing: HomeMetrics.codeSize * HomeMetrics.codeLetterSpacing,
      ),
      small: text(
        HomeMetrics.body12,
        lineHeight: HomeMetrics.body12LineHeight,
        color: t.textSecondary,
      ),
      tooltip: text(
        HomeMetrics.body12,
        lineHeight: HomeMetrics.body12LineHeight,
        weight: FontWeight.w500,
      ),
    );
  }

  final TextStyle greeting;
  final TextStyle emptyTitle;
  final TextStyle sectionTitle;
  final TextStyle dialogTitle;

  /// Inter 16/24 at 60 % (text under the empty-state title).
  final TextStyle lead;
  final TextStyle dialogSubtitle;
  final TextStyle pill;
  final TextStyle cardTitle;
  final TextStyle cardText;

  /// Inter 13/18 at 60 %: row details, notes, descriptions.
  final TextStyle detail;
  final TextStyle chip;
  final TextStyle legendLabel;
  final TextStyle legendAmount;
  final TextStyle axis;
  final TextStyle action;
  final TextStyle link;
  final TextStyle rowTitle;
  final TextStyle rowAmount;

  /// Type chip of a movement.
  final TextStyle badge;
  final TextStyle tab;
  final TextStyle overline;
  final TextStyle menuName;
  final TextStyle menuNickname;
  final TextStyle menuOption;
  final TextStyle footer;
  final TextStyle code;

  /// Inter 12/16 at 60 % (helpers under the code box).
  final TextStyle small;
  final TextStyle tooltip;
}
