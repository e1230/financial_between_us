/// Sizes and timings of the payment accounts module (design 360×800 and
/// 412×915) that the theme tokens do not cover.
abstract final class PaymentAccountsMetrics {
  static const double touchTarget = 48;

  // Top bar
  static const double barTop = 8;
  static const double backInset = 4;
  static const double backIconSize = 24;
  static const double addButtonSize = 44;
  static const double addButtonInset = 12;
  static const double addIconSize = 22;

  // Title block (gap below the bar, then title and subtitle)
  static const double titleGap = 12;
  static const double subtitleGap = 6;
  static const double listGap = 32;
  static const double hintGap = 20;
  static const double hintIconSize = 18;
  static const double hintIconGap = 12;

  // Typography (sizes and line heights in dp; wide = width ≥ 400)
  static const double titleSize = 32;
  static const double titleLineHeight = 38;
  static const double titleSizeWide = 36;
  static const double titleLineHeightWide = 44;
  static const double titleLetterSpacing = -0.02; // em
  static const double subtitleSize = 14;
  static const double subtitleLineHeight = 20;
  static const double subtitleSizeWide = 15;
  static const double subtitleLineHeightWide = 22;
  static const double rowNameSize = 16;
  static const double rowNameLineHeight = 22;
  static const double rowNameSizeWide = 17;
  static const double rowNameLineHeightWide = 24;
  static const double rowReferenceSize = 14;
  static const double rowReferenceLineHeight = 20;
  static const double rowReferenceSizeWide = 15;
  static const double rowReferenceLineHeightWide = 20;
  static const double hintSize = 13;
  static const double hintLineHeight = 18;
  static const double emptyTitleSize = 22;
  static const double emptyTitleLineHeight = 28;
  static const double emptyTextSize = 16;
  static const double emptyTextLineHeight = 24;
  static const double sheetNameSize = 20;
  static const double sheetNameLineHeight = 26;
  static const double labelSize = 12;
  static const double labelLineHeight = 16;
  static const double labelLetterSpacing = 0.04; // em
  static const double chipTextSize = 13;
  static const double chipTextLineHeight = 18;
  static const double valueSize = 32;
  static const double valueLineHeight = 40;
  static const double valueSmallSize = 22;
  static const double valueSmallLineHeight = 30;
  static const double valueLetterSpacing = 0.01; // em
  static const double cashTitleSize = 24;
  static const double cashTitleLineHeight = 32;
  static const double formTitleSize = 28;
  static const double formTitleLineHeight = 34;

  /// Longer references use the smaller value style in the detail.
  static const int longValueLength = 16;

  // List
  static const double listInset = 16;
  static const double rowMinHeight = 72;
  static const double rowPaddingV = 12;
  static const double rowPaddingH = 16;
  static const double rowGap = 16;
  static const double rowTextGap = 2;
  static const double dividerInset = 16;
  static const int skeletonRows = 3;
  static const double skeletonNameWidth = 0.45;
  static const double skeletonReferenceWidth = 0.3;
  static const double skeletonLine = 12;

  // Logo
  static const double logoSmall = 32;
  static const double logoSmallRadius = 8;
  static const double logoSmallIcon = 20;
  static const double logoLarge = 56;
  static const double logoLargeRadius = 14;
  static const double logoLargeIcon = 34;
  static const double logoDashWidth = 1.5;
  static const double logoPlaceholderIcon = 0.7; // of the symbol size

  // Empty state
  static const double emptyTopGap = 138;
  static const double emptyArtSize = 88;
  static const double emptyArtBackTop = 12;
  static const double emptyArtLogoLeft = 24;
  static const double emptyArtLogoTop = 20;
  static const double emptyArtTilt = -8; // degrees
  static const double emptyTitleGap = 20;
  static const double emptyTextMaxWidth = 300;
  static const double bottomButtonGap = 40;
  static const double buttonIconSize = 20;
  static const double buttonIconGap = 8;

  // Detail sheet
  static const double sheetRadius = 24;
  static const double sheetPaddingTop = 12;
  static const double handleWidth = 32;
  static const double handleHeight = 4;
  static const double handleRadius = 2;
  static const double sheetHeaderGap = 20;
  static const double sheetLogoGap = 16;
  static const double boxGap = 24;
  static const double boxRadius = 16;
  static const double boxPadding = 20;
  static const double boxInnerGap = 8;
  static const double chipPaddingV = 4;
  static const double chipPaddingH = 10;
  static const double buttonsGap = 12;
  static const double scrimOpacity = 0.6;

  // Menu
  static const double menuWidth = 184;
  static const double menuItemHeight = 48;
  static const double menuIconSize = 20;
  static const double menuPaddingV = 4;

  // Form
  static const double formFieldsGap = 22;
  static const double fieldGap = 16;
  static const double tilesGap = 12;
  static const double tileGap = 6;
  static const double tileHeight = 76;
  static const double tilePaddingV = 8;
  static const double tilePaddingH = 2;
  static const double tileInnerGap = 8;
  static const double tileBorder = 1.5;
  static const double typeFieldPaddingEnd = 12;
  static const double keyChipHeight = 36;
  static const double keyChipPaddingH = 14;
  static const double keyChipGap = 8;
  static const double keyLabelGap = 8;
  static const double disabledOpacity = 0.38;

  // Motion
  static const Duration rowEntry = Duration(milliseconds: 240);
  static const Duration rowStagger = Duration(milliseconds: 40);
  static const int maxStaggeredRows = 8;
  static const double rowEntryOffset = 8;
  static const Duration rowHighlight = Duration(milliseconds: 400);
  static const Duration rowHighlightFade = Duration(milliseconds: 100);
  static const Duration rowExit = Duration(milliseconds: 250);
  static const Duration sheetEntry = Duration(milliseconds: 300);
  static const Duration sheetExit = Duration(milliseconds: 220);
  static const Duration copiedFor = Duration(milliseconds: 1500);
  static const Duration morph = Duration(milliseconds: 200);
  static const Duration crossfade = Duration(milliseconds: 150);
  static const double morphStartScale = 0.6;
  static const Duration logoSwitch = Duration(milliseconds: 180);
  static const Duration logoSwitchOut = Duration(milliseconds: 90);
  static const Duration reducedFade = Duration(milliseconds: 150);
}
