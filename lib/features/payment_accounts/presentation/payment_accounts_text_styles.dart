import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_breakpoints.dart';
import '../../../core/theme/app_tokens.dart';
import 'payment_accounts_metrics.dart';

/// Text styles of the payment accounts module, derived from the app
/// [TextTheme]: Satoshi Bold for titles and Inter (tabular figures) for the
/// rest. Screens at least [AppBreakpoints.wide] wide get larger list text.
@immutable
class PaymentAccountsTextStyles {
  const PaymentAccountsTextStyles._({
    required this.title,
    required this.subtitle,
    required this.rowName,
    required this.rowReference,
    required this.hint,
    required this.emptyTitle,
    required this.emptyText,
    required this.sheetName,
    required this.sheetType,
    required this.boxLabel,
    required this.chip,
    required this.value,
    required this.valueSmall,
    required this.cashTitle,
    required this.cashText,
    required this.menuItem,
    required this.dialogTitle,
    required this.dialogText,
    required this.formTitle,
    required this.tileLabel,
    required this.sectionLabel,
  });

  factory PaymentAccountsTextStyles.of(BuildContext context) {
    final t = context.tokens;
    final theme = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.wide;
    final heading = theme.headlineLarge!.copyWith(color: t.textPrimary);
    final body = theme.bodyMedium!.copyWith(color: t.textPrimary);

    TextStyle head(double size, double lineHeight, {double spacing = 0}) =>
        heading.copyWith(
          fontSize: size,
          height: lineHeight / size,
          letterSpacing: spacing * size,
        );
    TextStyle text(
      double size,
      double lineHeight, {
      FontWeight weight = FontWeight.w400,
      Color? color,
      double spacing = 0,
    }) => body.copyWith(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      color: color ?? t.textPrimary,
      letterSpacing: spacing * size,
    );
    return PaymentAccountsTextStyles._(
      title: wide
          ? head(
              PaymentAccountsMetrics.titleSizeWide,
              PaymentAccountsMetrics.titleLineHeightWide,
              spacing: PaymentAccountsMetrics.titleLetterSpacing,
            )
          : head(
              PaymentAccountsMetrics.titleSize,
              PaymentAccountsMetrics.titleLineHeight,
              spacing: PaymentAccountsMetrics.titleLetterSpacing,
            ),
      subtitle: wide
          ? text(
              PaymentAccountsMetrics.subtitleSizeWide,
              PaymentAccountsMetrics.subtitleLineHeightWide,
              color: t.textSecondary,
            )
          : text(
              PaymentAccountsMetrics.subtitleSize,
              PaymentAccountsMetrics.subtitleLineHeight,
              color: t.textSecondary,
            ),
      rowName: wide
          ? text(
              PaymentAccountsMetrics.rowNameSizeWide,
              PaymentAccountsMetrics.rowNameLineHeightWide,
              weight: FontWeight.w500,
            )
          : text(
              PaymentAccountsMetrics.rowNameSize,
              PaymentAccountsMetrics.rowNameLineHeight,
              weight: FontWeight.w500,
            ),
      rowReference: wide
          ? text(
              PaymentAccountsMetrics.rowReferenceSizeWide,
              PaymentAccountsMetrics.rowReferenceLineHeightWide,
              color: t.textSecondary,
            )
          : text(
              PaymentAccountsMetrics.rowReferenceSize,
              PaymentAccountsMetrics.rowReferenceLineHeight,
              color: t.textSecondary,
            ),
      hint: text(
        PaymentAccountsMetrics.hintSize,
        PaymentAccountsMetrics.hintLineHeight,
        color: t.textSecondary,
      ),
      emptyTitle: head(
        PaymentAccountsMetrics.emptyTitleSize,
        PaymentAccountsMetrics.emptyTitleLineHeight,
      ),
      emptyText: text(
        PaymentAccountsMetrics.emptyTextSize,
        PaymentAccountsMetrics.emptyTextLineHeight,
        color: t.textSecondary,
      ),
      sheetName: head(
        PaymentAccountsMetrics.sheetNameSize,
        PaymentAccountsMetrics.sheetNameLineHeight,
      ),
      sheetType: text(
        PaymentAccountsMetrics.subtitleSize,
        PaymentAccountsMetrics.subtitleLineHeight,
        color: t.textSecondary,
      ),
      boxLabel: text(
        PaymentAccountsMetrics.labelSize,
        PaymentAccountsMetrics.labelLineHeight,
        weight: FontWeight.w500,
        color: t.textSecondary,
        spacing: PaymentAccountsMetrics.labelLetterSpacing,
      ),
      chip: text(
        PaymentAccountsMetrics.chipTextSize,
        PaymentAccountsMetrics.chipTextLineHeight,
        weight: FontWeight.w500,
      ),
      value: text(
        PaymentAccountsMetrics.valueSize,
        PaymentAccountsMetrics.valueLineHeight,
        weight: FontWeight.w600,
        spacing: PaymentAccountsMetrics.valueLetterSpacing,
      ),
      valueSmall: text(
        PaymentAccountsMetrics.valueSmallSize,
        PaymentAccountsMetrics.valueSmallLineHeight,
        weight: FontWeight.w600,
        spacing: PaymentAccountsMetrics.valueLetterSpacing,
      ),
      cashTitle: text(
        PaymentAccountsMetrics.cashTitleSize,
        PaymentAccountsMetrics.cashTitleLineHeight,
        weight: FontWeight.w600,
      ),
      cashText: text(
        PaymentAccountsMetrics.subtitleSize,
        PaymentAccountsMetrics.subtitleLineHeight,
        color: t.textSecondary,
      ),
      menuItem: text(
        PaymentAccountsMetrics.rowNameSize,
        PaymentAccountsMetrics.rowNameLineHeight,
        weight: FontWeight.w500,
      ),
      dialogTitle: head(
        PaymentAccountsMetrics.sheetNameSize,
        PaymentAccountsMetrics.sheetNameLineHeight,
      ),
      dialogText: text(
        PaymentAccountsMetrics.subtitleSize,
        PaymentAccountsMetrics.subtitleLineHeight,
        color: t.textSecondary,
      ),
      formTitle: head(
        PaymentAccountsMetrics.formTitleSize,
        PaymentAccountsMetrics.formTitleLineHeight,
        spacing: PaymentAccountsMetrics.titleLetterSpacing,
      ),
      tileLabel: text(
        PaymentAccountsMetrics.labelSize,
        PaymentAccountsMetrics.labelLineHeight,
        weight: FontWeight.w500,
        color: t.textSecondary,
      ),
      sectionLabel: text(
        PaymentAccountsMetrics.labelSize,
        PaymentAccountsMetrics.labelLineHeight,
        weight: FontWeight.w500,
        color: t.textSecondary,
      ),
    );
  }

  /// "Cuentas de pago": Satoshi Bold 32/38 (36/44 wide).
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle rowName;
  final TextStyle rowReference;
  final TextStyle hint;
  final TextStyle emptyTitle;
  final TextStyle emptyText;
  final TextStyle sheetName;
  final TextStyle sheetType;

  /// "NÚMERO DE CELULAR": Inter 12/16 w500, 0.04 em, at 60 %.
  final TextStyle boxLabel;

  /// Key chip and key type chips: Inter 13/18 w500.
  final TextStyle chip;

  /// Reference in the detail: Inter 32/40 w600.
  final TextStyle value;

  /// Long reference (more than 16 characters): Inter 22/30 w600.
  final TextStyle valueSmall;
  final TextStyle cashTitle;
  final TextStyle cashText;
  final TextStyle menuItem;
  final TextStyle dialogTitle;
  final TextStyle dialogText;
  final TextStyle formTitle;
  final TextStyle tileLabel;
  final TextStyle sectionLabel;
}
