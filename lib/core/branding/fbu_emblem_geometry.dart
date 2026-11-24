import 'dart:ui';

/// Vector geometry of the FBU emblem, in the 400×400 coordinate system of the
/// source SVG (`design/fbu-icons/svg/fbu_icono.svg`).
///
/// These values describe the brand illustration itself, not UI layout, so
/// they live here instead of in `AppTokens`.
abstract final class FbuEmblemGeometry {
  static const double viewBox = 400;
  static const Offset center = Offset(200, 200);

  // Outer coin
  static const double outerRadius = 194;
  static const double outerStroke = 6;
  static const double reedingRadius = 184;
  static const double reedingStroke = 8;
  static const double reedingPitch = 7;
  static const double reedingMarkLength = 2;
  static const double innerRingRadius = 175;
  static const double discRadius = 142;
  static const double thinStroke = 2;

  // Rim text
  static const String rimText = 'FINANCIAL BETWEEN US';
  static const double rimTextRadius = 152;
  static const double rimTextSize = 21;
  static const double rimLetterSpacing = 4;
  static const double starLeftX = 42;
  static const double starRightX = 358;

  // People
  static const Offset headLeft = Offset(128, 180);
  static const Offset headRight = Offset(272, 180);
  static const double headRadius = 20;

  // Arrows
  static const double arrowStroke = 5;

  // Spinning "$" coin
  static const Offset coinCenter = Offset(200, 214);
  static const double coinRadius = 25;
  static const double coinStroke = 3;
  static const Offset dollarBarTop = Offset(200, 198);
  static const Offset dollarBarBottom = Offset(200, 230);
  static const double dollarBarStroke = 4;
  static const double dollarSStroke = 4.5;

  /// Top arrow (left → right).
  static final Path arrowA = Path()
    ..moveTo(140, 148)
    ..quadraticBezierTo(200, 104, 260, 148);

  /// Bottom arrow (right → left).
  static final Path arrowB = Path()
    ..moveTo(260, 272)
    ..quadraticBezierTo(200, 316, 140, 272);

  static final Path arrowHeadA = Path()
    ..moveTo(245, 149)
    ..lineTo(262, 150)
    ..lineTo(256, 134);

  static final Path arrowHeadB = Path()
    ..moveTo(155, 271)
    ..lineTo(138, 270)
    ..lineTo(144, 286);

  static final Path bodyLeft = Path()
    ..moveTo(92, 250)
    ..cubicTo(92, 224, 108, 210, 128, 210)
    ..cubicTo(148, 210, 164, 224, 164, 250)
    ..close();

  static final Path bodyRight = Path()
    ..moveTo(236, 250)
    ..cubicTo(236, 224, 252, 210, 272, 210)
    ..cubicTo(292, 210, 308, 224, 308, 250)
    ..close();

  static final Path dollarS = Path()
    ..moveTo(209, 206)
    ..cubicTo(207, 201, 193, 200, 192, 207)
    ..cubicTo(191, 213, 209, 214, 208, 221)
    ..cubicTo(207, 228, 193, 228, 191, 222);

  /// Four-pointed star centered at ([cx], 200).
  static Path star(double cx) => Path()
    ..moveTo(cx, 190)
    ..lineTo(cx + 3, 197)
    ..lineTo(cx + 10, 200)
    ..lineTo(cx + 3, 203)
    ..lineTo(cx, 210)
    ..lineTo(cx - 3, 203)
    ..lineTo(cx - 10, 200)
    ..lineTo(cx - 3, 197)
    ..close();
}

/// Proportions of the full logo (emblem + "FBU" wordmark), relative to the
/// 260 px emblem of the original design.
abstract final class FbuLogoMetrics {
  /// Emblem size of the original design; also the splash default.
  static const double designEmblemSize = 260;

  /// Emblem size for secondary screens (errors, placeholders).
  static const double compactEmblemSize = 160;

  static const double wordmarkFontSize = 64;
  static const double wordmarkLetterSpacing = 0.24; // × font size
  static const double wordmarkUnderlineGap = 12;
  static const double wordmarkUnderlineWidth = 48;
  static const double wordmarkUnderlineHeight = 5;

  /// Vertical gap between the emblem and the wordmark.
  static const double emblemToWordmarkGap = 24;

  /// How much the emblem rises when the wordmark appears in the splash.
  static const double splashLift = 70;

  /// Initial offset of the wordmark slide-in-up in the splash.
  static const double splashWordmarkSlide = 48;

  /// Scale factor of a logo of [emblemSize] relative to the design.
  static double scaleFor(double emblemSize) => emblemSize / designEmblemSize;
}
