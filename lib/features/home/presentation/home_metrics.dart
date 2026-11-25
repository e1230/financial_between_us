import 'package:material_ui/material_ui.dart';

/// Fixed layout and motion values of the Home module (design 360×800).
/// Colors, the 8-based spacing scale and radii come from `AppTokens` and
/// `UserPalette`; these are the module-specific measurements.
abstract final class HomeMetrics {
  // Touch targets
  static const double touchTarget = 48;

  // Text sizes (Satoshi titles, Inter body). Line heights are in dp.
  static const double greetingSize = 30;
  static const double greetingLineHeight = 36;
  static const double titleLetterSpacing = -0.02; // em
  static const double emptyTitleSize = 28;
  static const double emptyTitleLineHeight = 34;
  static const double sectionTitleSize = 18;
  static const double sectionTitleLineHeight = 24;
  static const double dialogTitleSize = 22;
  static const double dialogTitleLineHeight = 28;
  static const double body16 = 16;
  static const double body16LineHeight = 24;
  static const double cardTitleLineHeight = 22;
  static const double body15 = 15;
  static const double body15LineHeight = 20;
  static const double body13 = 13;
  static const double body13LineHeight = 18;
  static const double body14 = 14;
  static const double body14LineHeight = 20;
  static const double body12 = 12;
  static const double body12LineHeight = 16;
  static const double actionLineHeight = 16;
  static const double body11 = 11;
  static const double body11LineHeight = 16;
  static const double amountSize = 18;
  static const double amountLineHeight = 24;
  static const double codeSize = 24;
  static const double codeLetterSpacing = 0.12; // em
  static const double overlineLetterSpacing = 0.04; // em
  static const double menuNameLineHeight = 24;
  static const double menuOptionLineHeight = 22;

  // Header
  static const double headerTopGap = 8;
  static const double headerHeight = 48;
  static const double headerAvatarSize = 44;
  static const double headerAvatarRing = 2;
  static const double headerAvatarGap = 3;
  static const double menuAvatarGap = 4;
  static const double pillHeight = 40;
  static const double pillMaxWidth = 196;
  static const double pillPaddingStart = 16;
  static const double pillPaddingEnd = 12;
  static const double pillGap = 6;
  static const double chevronSize = 18;
  static const double headerIconSize = 22;
  static const double glassFillOpacity = 0.06;
  static const double glassBorderOpacity = 0.12;

  // Content
  static const double contentGap = 16; // below the header
  static const double emptyContentExtraGap = 12;
  static const double contentPadding = 24; // left and right
  static const double emptyTextMaxWidth = 300;
  static const double emptyCardsGap = 48;
  static const double emptyNoteGap = 32;
  static const double cardMinHeight = 112;
  static const double cardPadding = 20;
  static const double cardFillOpacity = 0.05;
  static const double cardBorderOpacity = 0.10;
  static const double cardBlur = 24;
  static const double cardIconBox = 48;
  static const double cardIconGap = 16;
  static const double cardChevronSize = 20;
  static const double noteIconSize = 18;
  static const double noteIconGap = 12;
  static const double iconSize = 22;

  // Gradient borders (see GradientBorderBox.brandGradient).
  static const double gradientBorder = 1.5;
  static const double gradientBorderPressed = 2;

  // Greeting and period chips
  static const double chipsGap = 12;
  static const double chipHeight = 32;
  static const double chipPadding = 14;
  static const double chipFillOpacity = 0.08;

  // Legend and chart
  static const double legendGap = 20;
  static const double legendDot = 8;
  static const double legendDotGap = 6;
  static const double legendLineGap = 2;
  static const double legendColumnGap = 12;
  static const double chartGap = 12;
  static const double chartHeight = 120;
  static const double chartAxisHeight = 20;
  static const double chartLineWidth = 2.5;
  static const double chartCurveSmoothness = 0.3;
  static const double chartDotRadius = 4.5;
  static const double chartDotStroke = 2.5;
  static const double chartPaidAreaOpacity = 0.26;
  static const double chartOweAreaOpacity = 0.18;
  static const double chartGridOpacity = 0.08;
  static const List<int> chartGridDash = [3, 5];
  static const int chartGridLines = 3;
  static const double chartMaxFactor = 1.1;
  static const Duration chartAnimation = Duration(milliseconds: 600);

  // Quick actions
  static const double actionsGap = 32;
  static const double actionHeight = 88;
  static const double actionPadding = 12;
  static const double actionIconCircle = 28;
  static const double actionIconSize = 16;
  static const double actionGap = 8;
  static const double pressedScale = 0.97;
  static const Duration pressDuration = Duration(milliseconds: 100);

  // Recent movements
  static const double movementPaddingVertical = 10;
  static const double movementIconCircle = 40;
  static const double movementIconSize = 20;
  static const double movementGap = 12;
  static const double movementChipPaddingH = 8;
  static const double movementChipPaddingV = 1;
  static const double movementDividerOpacity = 0.06;
  static const double semanticTintOpacity = 0.12;
  static const int skeletonRows = 3;
  static const double skeletonLine = 12;

  // Bottom bar
  static const double barHeight = 64;
  static const double barPaddingH = 8;
  static const double tabWidth = 64;
  static const double tabMinHeight = 52;
  static const double tabIconSize = 22;
  static const double tabGap = 4;
  static const double tabIndicatorWidth = 56;
  static const double tabIndicatorHeight = 30;
  static const double tabIndicatorOpacity = 0.14;
  static const double addButtonSize = 64;
  static const double addButtonRing = 4;
  static const double addButtonRaise = 20;
  static const double addIconSize = 26;
  static const double addOpenTurns = 0.125;
  static const Duration addRotation = Duration(milliseconds: 250);

  // + popover
  static const double popoverWidth = 260;
  static const double popoverArrowHeight = 8;
  static const double popoverArrowWidth = 14;
  static const int popoverBarrierAlpha = 140;
  static const double popoverPadding = 8;
  static const double popoverRowMinHeight = 64;
  static const double popoverRowPaddingH = 12;
  static const double popoverIconCircle = 40;
  static const double popoverIconSize = 20;

  // Group selector
  static const double selectorGap = 8;
  static const double selectorPadding = 8;
  static const double selectorBarrierOpacity = 0.5;
  static const double selectorRowHeight = 64;
  static const double selectorActionHeight = 52;
  static const double selectorTile = 40;
  static const double selectorCheckSize = 22;
  static const double selectorPendingOpacity = 0.6;
  static const double selectorDividerMarginV = 8;
  static const double selectorDividerMarginH = 12;
  static const double selectorStartScale = 0.96;
  static const double selectorMaxHeightFactor = 0.7;
  static const double tileGreenOpacity = 0.20;
  static const double tileTealOpacity = 0.80;

  // Avatar menu
  static const Duration menuTransition = Duration(milliseconds: 450);
  static const Duration menuContentDuration = Duration(milliseconds: 300);
  static const Duration menuContentDelay = Duration(milliseconds: 100);
  static const double menuContentOffset = 16;
  static const double menuCloseInset = 4;

  /// Below the safe area (104 in the 360×800 design, with a 32 dp status bar).
  static const double menuProfileTop = 72;
  static const double menuProfileMinHeight = 88;
  static const double menuAvatarSize = 64;
  static const double menuOptionMinHeight = 72;
  static const double menuOptionIconGap = 20;
  static const double menuIconSize = 24;
  static const double menuChevronSize = 20;

  // Dialogs
  static const double successCircle = 56;
  static const double successIcon = 28;
  static const double codeBoxHeight = 64;
  static const double codeBoxPaddingStart = 20;
  static const double codeBoxPaddingEnd = 8;
  static const double copyIconSize = 18;
  static const Duration copiedReset = Duration(seconds: 2);
  static const double switchWidth = 52;
  static const double switchHeight = 32;
  static const double switchBorder = 2;
  static const double switchThumbOff = 16;
  static const double switchThumbOn = 24;
  static const double textButtonHeight = 48;

  // Motion
  static const Duration crossfade = Duration(milliseconds: 250);
  static const Duration reducedMotionFade = Duration(milliseconds: 150);

  /// Every curve of the module that is not linear.
  static const Curve easeOutCubic = Curves.easeOutCubic;
}
