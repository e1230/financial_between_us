import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'arrow_frame.dart';
import 'fbu_emblem_geometry.dart';

typedef _G = FbuEmblemGeometry;

/// Brand palette of the emblem, resolved from [AppTokens].
@immutable
class FbuEmblemPalette {
  const FbuEmblemPalette({
    required this.accent,
    required this.foreground,
    required this.coin,
    required this.disc,
    required this.fontFamily,
  });

  factory FbuEmblemPalette.fromTokens(AppTokens tokens) => FbuEmblemPalette(
    accent: tokens.accent,
    foreground: tokens.textPrimary,
    coin: tokens.brandCoin,
    disc: tokens.background,
    fontFamily: tokens.brandFontFamily,
  );

  /// Green: outer ring, rim text, left person, top arrow, "$".
  final Color accent;

  /// White: right person and bottom arrow.
  final Color foreground;

  /// Fill of the outer coin and of the "$" coin.
  final Color coin;

  /// Fill of the inner disc.
  final Color disc;

  /// Brand typeface for the rim text.
  final String fontFamily;

  /// Coin edge reeding (accent at 50 %).
  Color get reeding => accent.withValues(alpha: 0.5);

  @override
  bool operator ==(Object other) =>
      other is FbuEmblemPalette &&
      other.accent == accent &&
      other.foreground == foreground &&
      other.coin == coin &&
      other.disc == disc &&
      other.fontFamily == fontFamily;

  @override
  int get hashCode => Object.hash(accent, foreground, coin, disc, fontFamily);
}

Paint _stroke(Color color, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..color = color
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint _fill(Color color) => Paint()..color = color;

/// Static layer of the emblem: coin, reeding, rim text, stars and people.
///
/// Painted once (behind a `RepaintBoundary`) so the animated layer can repaint
/// every frame without redrawing the text.
class FbuEmblemBasePainter extends CustomPainter {
  const FbuEmblemBasePainter({required this.palette});

  final FbuEmblemPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _G.viewBox, size.height / _G.viewBox);

    canvas.drawCircle(_G.center, _G.outerRadius, _fill(palette.coin));
    canvas.drawCircle(
      _G.center,
      _G.outerRadius,
      _stroke(palette.accent, _G.outerStroke),
    );
    _drawReeding(canvas);
    canvas.drawCircle(
      _G.center,
      _G.innerRingRadius,
      _stroke(palette.accent, _G.thinStroke),
    );
    canvas.drawCircle(_G.center, _G.discRadius, _fill(palette.disc));
    canvas.drawCircle(
      _G.center,
      _G.discRadius,
      _stroke(palette.accent, _G.thinStroke),
    );

    _drawRimText(canvas);
    canvas.drawPath(_G.star(_G.starLeftX), _fill(palette.accent));
    canvas.drawPath(_G.star(_G.starRightX), _fill(palette.accent));

    canvas.drawCircle(_G.headLeft, _G.headRadius, _fill(palette.accent));
    canvas.drawPath(_G.bodyLeft, _fill(palette.accent));
    canvas.drawCircle(_G.headRight, _G.headRadius, _fill(palette.foreground));
    canvas.drawPath(_G.bodyRight, _fill(palette.foreground));

    canvas.restore();
  }

  void _drawReeding(Canvas canvas) {
    const r = _G.reedingRadius;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _G.reedingStroke
      ..color = palette.reeding
      ..strokeCap = StrokeCap.butt;
    final rect = Rect.fromCircle(center: _G.center, radius: r);
    final count = (2 * math.pi * r / _G.reedingPitch).floor();
    final step = 2 * math.pi / count;
    const sweep = _G.reedingMarkLength / r;
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * step, sweep, false, paint);
    }
  }

  /// Text along the top of the rim, centered, glyphs facing outwards.
  void _drawRimText(Canvas canvas) {
    final style = TextStyle(
      fontFamily: palette.fontFamily,
      fontSize: _G.rimTextSize,
      fontWeight: FontWeight.w700,
      color: palette.accent,
    );
    final glyphs = [
      for (final ch in _G.rimText.split(''))
        TextPainter(
          text: TextSpan(text: ch, style: style),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final total =
        glyphs.fold<double>(
          0,
          (sum, g) => sum + g.width + _G.rimLetterSpacing,
        ) -
        _G.rimLetterSpacing;
    var cursor = -total / 2;
    for (final g in glyphs) {
      // 0 rad = top, positive = clockwise.
      final theta = (cursor + g.width / 2) / _G.rimTextRadius;
      final baseline = g.computeDistanceToActualBaseline(
        TextBaseline.alphabetic,
      );
      canvas.save();
      canvas.translate(_G.center.dx, _G.center.dy);
      canvas.rotate(theta);
      canvas.translate(0, -_G.rimTextRadius);
      g.paint(canvas, Offset(-g.width / 2, -baseline));
      canvas.restore();
      cursor += g.width + _G.rimLetterSpacing;
      g.dispose();
    }
  }

  @override
  bool shouldRepaint(FbuEmblemBasePainter oldDelegate) =>
      oldDelegate.palette != palette;
}

/// Animated layer of the emblem: both arrows and the spinning "$" coin.
class FbuEmblemMotionPainter extends CustomPainter {
  const FbuEmblemMotionPainter({
    required this.palette,
    this.coinAngle = 0,
    this.arrowA = ArrowFrame.complete,
    this.arrowB = ArrowFrame.complete,
  });

  final FbuEmblemPalette palette;

  /// Rotation of the "$" coin in radians (clockwise).
  final double coinAngle;
  final ArrowFrame arrowA;
  final ArrowFrame arrowB;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _G.viewBox, size.height / _G.viewBox);

    _drawArrow(canvas, _G.arrowA, _G.arrowHeadA, palette.accent, arrowA);
    _drawArrow(canvas, _G.arrowB, _G.arrowHeadB, palette.foreground, arrowB);
    _drawCoin(canvas);

    canvas.restore();
  }

  void _drawCoin(Canvas canvas) {
    const c = _G.coinCenter;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(coinAngle);
    canvas.translate(-c.dx, -c.dy);
    canvas.drawCircle(c, _G.coinRadius, _fill(palette.coin));
    canvas.drawCircle(c, _G.coinRadius, _stroke(palette.accent, _G.coinStroke));
    canvas.drawLine(
      _G.dollarBarTop,
      _G.dollarBarBottom,
      _stroke(palette.accent, _G.dollarBarStroke),
    );
    canvas.drawPath(_G.dollarS, _stroke(palette.accent, _G.dollarSStroke));
    canvas.restore();
  }

  void _drawArrow(
    Canvas canvas,
    Path path,
    Path head,
    Color color,
    ArrowFrame frame,
  ) {
    if (frame.isStrokeVisible) {
      final metric = path.computeMetrics().first;
      canvas.drawPath(
        metric.extractPath(
          metric.length * frame.start,
          metric.length * frame.end,
        ),
        _stroke(color.withValues(alpha: frame.opacity), _G.arrowStroke),
      );
    }
    if (frame.headOpacity > 0) {
      canvas.drawPath(
        head,
        _stroke(color.withValues(alpha: frame.headOpacity), _G.arrowStroke),
      );
    }
  }

  @override
  bool shouldRepaint(FbuEmblemMotionPainter oldDelegate) =>
      oldDelegate.palette != palette ||
      oldDelegate.coinAngle != coinAngle ||
      oldDelegate.arrowA != arrowA ||
      oldDelegate.arrowB != arrowB;
}
