import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_breakpoints.dart';

/// Fixed layout and motion values of the walkthrough (design 360×800 and
/// 412×915). Colors, the 8-based spacing scale and radii of cards/buttons come
/// from `AppTokens`; these are the module-specific measurements.
abstract final class WalkthroughMetrics {
  /// Screens at least this wide use [WalkthroughLayout.wide].
  static const double wideBreakpoint = AppBreakpoints.wide;

  // Progress bar
  static const double progressHeight = 3;
  static const double progressGap = 4;
  static const double progressRadius = 2;

  // Header
  static const double headerHeight = 48;
  static const double emblemSize = 24;
  static const double headerLabelFontSize = 15;

  // Page dots
  static const double dotSize = 8;
  static const double dotActiveWidth = 24;
  static const double dotRadius = 4;

  /// Text scale above which the title may use a third line.
  static const double largeTextScale = 1.3;
  static const int titleMaxLines = 2;
  static const int titleMaxLinesLargeText = 3;
  static const int subtitleMaxLines = 2;

  // Scrims: (#111111 alpha, stop) pairs.
  static const List<double> topScrimAlphas = [0.72, 0.32, 0];
  static const List<double> topScrimStops = [0, 0.55, 1];
  static const List<double> bottomScrimAlphas = [1, 1, 0.82, 0.45, 0.12, 0];
  static const List<double> bottomScrimStops = [
    0,
    0.26,
    0.36,
    0.45,
    0.51,
    0.55,
  ];

  // Motion
  static const Duration autoAdvance = Duration(seconds: 6);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Curve pageTransitionCurve = Curves.easeOutCubic;
  static const Duration kenBurns = Duration(seconds: 8);
  static const double kenBurnsScale = 0.08;
  static const double kenBurnsShiftX = 0.02; // × width
  static const double kenBurnsShiftY = 0.01; // × height

  /// The photo moves at this fraction of the finger speed.
  static const double parallaxFactor = 0.5;

  /// Text fades out completely after a third of a page swipe.
  static const double textExitFadeFactor = 3;
  static const Duration textEntry = Duration(milliseconds: 400);
  static const Duration subtitleEntryDelay = Duration(milliseconds: 80);
  static const double textEntryOffset = 16;
  static const Duration dots = Duration(milliseconds: 250);
  static const double buttonLabelRise = 8;
}

/// Measurements that change with the screen width.
@immutable
class WalkthroughLayout {
  const WalkthroughLayout._({
    required this.topScrimHeight,
    required this.titleFontSize,
    required this.titleLineHeight,
    required this.titleLetterSpacing,
    required this.titleToSubtitleGap,
    required this.textToDotsGap,
    required this.textMaxWidth,
  });

  static const WalkthroughLayout compact = WalkthroughLayout._(
    topScrimHeight: 160,
    titleFontSize: 32,
    titleLineHeight: 38,
    titleLetterSpacing: -0.64,
    titleToSubtitleGap: 12,
    textToDotsGap: 32,
    textMaxWidth: 300,
  );

  static const WalkthroughLayout wide = WalkthroughLayout._(
    topScrimHeight: 176,
    titleFontSize: 36,
    titleLineHeight: 44,
    titleLetterSpacing: -0.72,
    titleToSubtitleGap: 16,
    textToDotsGap: 40,
    textMaxWidth: 340,
  );

  static WalkthroughLayout of(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= WalkthroughMetrics.wideBreakpoint
      ? wide
      : compact;

  final double topScrimHeight;
  final double titleFontSize;
  final double titleLineHeight;
  final double titleLetterSpacing;
  final double titleToSubtitleGap;
  final double textToDotsGap;
  final double textMaxWidth;
}
