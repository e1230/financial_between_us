import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

typedef _G = FbuMiniEmblemGeometry;

/// Simplified FBU emblem for small sizes (≤ 64 dp): two people exchanging,
/// with the two arcs and without the coin.
///
/// Drawn from the source SVG (`fbu_emblema.svg`, viewBox `72 74 256 256`) so
/// it stays crisp at any density and takes its colors from [AppTokens].
/// It is decorative: always paired with a text label, so it adds no
/// semantics.
class FbuMiniEmblem extends StatelessWidget {
  const FbuMiniEmblem({super.key, this.size = FbuMiniEmblemGeometry.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: FbuMiniEmblemPainter(
            accent: tokens.accent,
            foreground: tokens.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Vector geometry of the mini emblem, in the coordinates of the source SVG.
///
/// These values describe the brand illustration itself, not UI layout, so
/// they live here instead of in `AppTokens`.
abstract final class FbuMiniEmblemGeometry {
  /// Default rendered size (header of the walkthrough).
  static const double size = 24;

  static const Offset viewBoxOrigin = Offset(72, 74);
  static const double viewBoxSize = 256;

  static const double arcStroke = 16;
  static const double headRadius = 26;
  static const Offset headLeft = Offset(128, 180);
  static const Offset headRight = Offset(272, 180);

  /// Horizontal distance from a head center to its shoulder edge.
  static const double shoulderHalfWidth = 36;
  static const double shoulderTop = 210;
  static const double shoulderBottom = 250;
}

class FbuMiniEmblemPainter extends CustomPainter {
  const FbuMiniEmblemPainter({required this.accent, required this.foreground});

  /// Top arc and left person.
  final Color accent;

  /// Bottom arc and right person.
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _G.viewBoxSize;
    canvas
      ..save()
      ..scale(scale)
      ..translate(-_G.viewBoxOrigin.dx, -_G.viewBoxOrigin.dy);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _G.arcStroke
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..style = PaintingStyle.fill;

    // Top arc: M 140,148 Q 200,104 260,148
    canvas.drawPath(
      Path()
        ..moveTo(140, 148)
        ..quadraticBezierTo(200, 104, 260, 148),
      stroke..color = accent,
    );
    // Bottom arc: M 260,272 Q 200,316 140,272
    canvas.drawPath(
      Path()
        ..moveTo(260, 272)
        ..quadraticBezierTo(200, 316, 140, 272),
      stroke..color = foreground,
    );

    _drawPerson(canvas, _G.headLeft, fill..color = accent);
    _drawPerson(canvas, _G.headRight, fill..color = foreground);
    canvas.restore();
  }

  /// Head plus rounded shoulders, centered under the head.
  void _drawPerson(Canvas canvas, Offset head, Paint paint) {
    canvas.drawCircle(head, _G.headRadius, paint);
    final left = head.dx - _G.shoulderHalfWidth;
    final right = head.dx + _G.shoulderHalfWidth;
    // M 92,250 C 92,224 108,210 128,210 C 148,210 164,224 164,250 Z
    canvas.drawPath(
      Path()
        ..moveTo(left, _G.shoulderBottom)
        ..cubicTo(
          left,
          224,
          head.dx - 20,
          _G.shoulderTop,
          head.dx,
          _G.shoulderTop,
        )
        ..cubicTo(
          head.dx + 20,
          _G.shoulderTop,
          right,
          224,
          right,
          _G.shoulderBottom,
        )
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(FbuMiniEmblemPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.foreground != foreground;
}
