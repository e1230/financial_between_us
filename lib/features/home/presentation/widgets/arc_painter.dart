import 'package:material_ui/material_ui.dart';

/// Colors of the Home arc.
@immutable
class ArcColors {
  const ArcColors({
    required this.center,
    required this.tint,
    required this.green,
    required this.teal,
    required this.cutTop,
    required this.cutBottom,
  });

  /// The user's color, at the middle of the arc.
  final Color center;

  /// The user's color at 20 %, the light reflected inside the arc.
  final Color tint;
  final Color green;
  final Color teal;
  final Color cutTop;
  final Color cutBottom;

  @override
  bool operator ==(Object other) =>
      other is ArcColors &&
      other.center == center &&
      other.tint == tint &&
      other.green == green &&
      other.teal == teal &&
      other.cutTop == cutTop &&
      other.cutBottom == cutBottom;

  @override
  int get hashCode => Object.hash(center, tint, green, teal, cutTop, cutBottom);
}

/// The glowing arc behind the Home: a huge ellipse whose lower rim shows as
/// a moon of light near 46 % of the screen height.
///
/// Three layers: a blurred glow filled with the horizontal gradient, the
/// same ellipse 16 dp higher filled dark (with a faint radial reflection at
/// its bottom) that hides all but the rim, and a thin gradient border.
class ArcPainter extends CustomPainter {
  const ArcPainter(this.colors);

  final ArcColors colors;

  // Ellipse relative to the screen.
  static const double widthFactor = 1.70;
  static const double heightFactor = 0.82;
  static const double leftFactor = -0.35;
  static const double topFactor = -0.36;

  static const double glowOpacity = 0.9;
  static const double glowSigma = 14;
  static const double cutOffset = 16;
  static const double reflectionWidth = 0.55;
  static const double reflectionHeight = 0.38;
  static const double reflectionFadeStop = 0.7;
  static const double borderWidth = 1.5;
  static const double borderOpacity = 0.85;
  static const List<double> gradientStops = [0, 0.28, 0.5, 0.72, 1];

  /// The base ellipse for a screen of [size].
  static Rect ellipseFor(Size size) => Rect.fromLTWH(
    size.width * leftFactor,
    size.height * topFactor,
    size.width * widthFactor,
    size.height * heightFactor,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final base = ellipseFor(size);
    final cut = base.shift(const Offset(0, -cutOffset));
    final horizontal = LinearGradient(
      colors: [
        colors.teal,
        colors.green,
        colors.center,
        colors.green,
        colors.teal,
      ],
      stops: gradientStops,
    );

    // 1. Glow.
    canvas.drawOval(
      base,
      Paint()
        ..shader = horizontal.createShader(base)
        ..color = const Color(0xFF000000).withValues(alpha: glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, glowSigma),
    );

    // 2. Cut-out with the reflection at its bottom.
    canvas.drawOval(
      cut,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.cutTop, colors.cutBottom],
        ).createShader(cut),
    );
    final rx = cut.width * reflectionWidth;
    final ry = cut.height * reflectionHeight;
    canvas
      ..save()
      ..clipPath(Path()..addOval(cut))
      ..translate(cut.center.dx, cut.bottom)
      ..scale(1, ry / rx);
    final reflection = Rect.fromCircle(center: Offset.zero, radius: rx);
    canvas
      ..drawCircle(
        Offset.zero,
        rx,
        Paint()
          ..shader = RadialGradient(
            colors: [colors.tint, colors.tint.withValues(alpha: 0)],
            stops: const [0, reflectionFadeStop],
          ).createShader(reflection),
      )
      ..restore();

    // 3. Rim.
    canvas.drawOval(
      cut,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..shader = horizontal.createShader(cut)
        ..color = const Color(0xFF000000).withValues(alpha: borderOpacity),
    );
  }

  @override
  bool shouldRepaint(ArcPainter oldDelegate) => oldDelegate.colors != colors;
}
