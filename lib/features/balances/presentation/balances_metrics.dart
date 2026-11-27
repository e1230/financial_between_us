import 'package:material_ui/material_ui.dart';

/// Sizes, opacities and durations of the balances module (designed at
/// 360×800). Colors come from `AppTokens` and
/// `UserPalette`.
abstract final class BalancesMetrics {
  // Wide screens (≥ AppBreakpoints.wide) scale the type about 7 %.
  static const double wideTypeScale = 1.07;

  // Header
  static const double headerTopGap = 8;
  static const double headerHeight = 48;
  static const double titleLeft = 24;
  static const double titleSize = 28;
  static const double titleLineHeight = 34;
  static const double titleCollapsedSize = 20;
  static const double titleCollapsedLineHeight = 26;
  static const double titleLetterSpacing = -0.01;

  // Tabs
  static const double tabsHeight = 44;
  static const double tabsPadding = 4;
  static const double tabsBottomGap = 12;
  static const double tabTextSize = 14;
  static const double tabTextLineHeight = 20;

  // Summary card
  static const double summaryPadding = 20;
  static const double netSize = 36;
  static const double netLineHeight = 44;
  static const double barGap = 16;
  static const double barHeight = 10;
  static const double barSegmentGap = 4;
  static const double legendGap = 12;
  static const double legendDot = 8;
  static const double legendDotGap = 8;
  static const double legendAmountSize = 18;
  static const double legendAmountLineHeight = 24;

  // Lists
  static const double listTopGap = 16;
  static const double sectionGap = 24;
  static const double sectionLabelPaddingH = 8;
  static const double sectionLabelBottomGap = 8;
  static const double labelSize = 12;
  static const double labelLineHeight = 16;
  static const double labelLetterSpacing = 0.04;
  static const double rowMinHeight = 64;
  static const double rowPaddingV = 12;
  static const double rowPaddingH = 16;
  static const double rowGap = 12;
  static const double avatar = 40;
  static const double dividerInset = 68;
  static const double rowTitleSize = 15;
  static const double rowTitleLineHeight = 20;
  static const double rowDetailSize = 13;
  static const double rowDetailLineHeight = 18;
  static const double settledOpacity = 0.72;
  static const double shieldIcon = 20;
  static const double chevronSize = 24;

  // All clear
  static const double allClearCircle = 56;
  static const double allClearIcon = 28;
  static const double allClearTitleSize = 20;
  static const double allClearTitleLineHeight = 26;

  // Person detail
  static const double backSize = 48;
  static const double backLeft = 4;
  static const double personHeaderTop = 96;
  static const double personAvatar = 56;
  static const double personHeaderGap = 16;
  static const double personNameSize = 22;
  static const double personNameLineHeight = 28;
  static const double personSubSize = 14;
  static const double personSubLineHeight = 20;
  static const double balanceAmountSize = 32;
  static const double balanceAmountLineHeight = 40;
  static const double remindHeight = 36;
  static const double remindPaddingH = 14;
  static const double remindIcon = 18;
  static const double shieldCircle = 48;
  static const double shieldCircleIcon = 24;
  static const double pendingRowMinHeight = 72;
  static const double progressHeight = 3;
  static const double collapseAfter = 120;
  static const double collapsedAvatar = 32;
  static const double collapsedNameSize = 17;
  static const double collapsedNameLineHeight = 22;
  static const double filterHeight = 32;
  static const double filterPaddingH = 14;
  static const double historyRowMinHeight = 64;
  static const double historyRowPaddingV = 12;
  static const double newDot = 8;
  static const double clipIcon = 14;
  static const double accountCopyButton = 48;

  // Chips
  static const double chipTextSize = 11;
  static const double chipTextLineHeight = 16;
  static const double chipPaddingV = 1;
  static const double chipPaddingH = 8;

  // Action bar
  static const double actionBarTop = 24;
  static const double actionBarBottom = 40;
  static const double actionBarGap = 12;
  static const double actionBarFade = 24;
  static const double toastAboveActions = 128;

  // Sheets
  static const double sheetPaddingTop = 12;
  static const double sheetHeaderGap = 20;
  static const double sheetTitleSize = 20;
  static const double sheetTitleLineHeight = 26;
  static const double sheetSubtitleSize = 14;
  static const double sheetSubtitleLineHeight = 20;
  static const double amountFieldHeight = 72;
  static const double amountSize = 28;
  static const double amountLineHeight = 34;
  static const double focusBorder = 1.5;
  static const double quickChipHeight = 40;
  static const double appliesRowHeight = 48;
  static const double checkbox = 20;
  static const double checkboxRadius = 6;
  static const double checkIcon = 16;
  static const double accountChipHeight = 48;
  static const double accountRadioHeight = 56;
  static const double radioSize = 20;
  static const double radioDot = 10;
  static const double copySmallButton = 44;
  static const double toggleHeight = 44;
  static const double fieldHeight = 56;
  static const double detailRowHeight = 48;
  static const double detailAmountSize = 32;
  static const double detailAmountLineHeight = 40;
  static const double thumbnailHeight = 132;
  static const double scrimOpacity = 0.6;

  // Attachment
  static const double attachMinHeight = 56;
  static const double attachDash = 6;
  static const double attachGap = 4;
  static const double attachIcon = 20;
  static const double attachedHeight = 64;
  static const double thumb = 48;
  static const double thumbRadius = 8;
  static const double attachEntryScale = 0.9;
  static const double viewerMaxScale = 4;

  // Tints over a semantic color (green or red at 12 %, white at 8 %).
  static const double semanticTint = 0.12;
  static const double neutralTint = 0.08;
  static const double historyDividerOpacity = 0.06;

  /// Minimum touch target.
  static const double touchTarget = 48;

  // Motion
  static const Duration netCount = Duration(milliseconds: 600);
  static const Duration netRecount = Duration(milliseconds: 400);
  static const Duration barGrow = Duration(milliseconds: 500);
  static const Duration barRedDelay = Duration(milliseconds: 80);
  static const Duration rowEntry = Duration(milliseconds: 240);
  static const Duration rowStagger = Duration(milliseconds: 40);
  static const int staggerMax = 8;
  static const double rowEntryOffset = 8;
  static const Duration tabSlide = Duration(milliseconds: 250);
  static const Duration crossfade = Duration(milliseconds: 200);
  static const Duration chevronTurn = Duration(milliseconds: 200);
  static const Duration settledResize = Duration(milliseconds: 250);
  static const Duration settledFade = Duration(milliseconds: 150);
  static const Duration heroFlight = Duration(milliseconds: 350);
  static const Duration detailEntry = Duration(milliseconds: 300);
  static const Duration detailEntryDelay = Duration(milliseconds: 80);
  static const double detailEntryOffset = 16;
  static const Duration headerCollapse = Duration(milliseconds: 150);
  static const Duration checkboxFade = Duration(milliseconds: 120);
  static const Duration attachSwap = Duration(milliseconds: 150);
  static const Duration attachResize = Duration(milliseconds: 200);
  static const Duration balanceRecount = Duration(milliseconds: 500);
  static const Duration settledSwap = Duration(milliseconds: 250);
  static const Duration shieldPop = Duration(milliseconds: 300);
  static const double shieldStartScale = 0.6;
  static const Duration strike = Duration(milliseconds: 250);
  static const Duration chipSwap = Duration(milliseconds: 150);
  static const Duration highlight = Duration(seconds: 2);
  static const Duration reducedFade = Duration(milliseconds: 150);

  static const Curve countCurve = Curves.easeOutCubic;
}
