// Splash animado de Financial Between Us.
//
// Recrea en Flutter puro (sin dependencias) la animación del canvas:
//   1. 0.0 – 0.6 s  ZoomIn del logo sobre fondo negro.
//   2. 0.6 – 2.8 s  El "$" gira a la derecha y las flechas se dibujan de la
//                   cola a la punta y se borran en el mismo orden (en bucle).
//                   Si pasas `waitFor`, esta fase se alarga hasta que termine.
//   3. Salida       El logo sube, "FBU" entra con slideInUp, 1 s quieto y
//                   todo se desvanece. Al terminar se llama `onFinished`.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Colores de marca.
class FbuColors {
  FbuColors._();
  static const Color green = Color(0xFF28DE4B);
  static const Color white = Color(0xFFF2F2F2);
  static const Color background = Color(0xFF000000);
  static const Color coin = Color(0xFF0A0A0A);
  static const Color disc = Color(0xFF111111);
  static const Color reeding = Color(0x8028DE4B); // verde al 50 %
}

/// Familia declarada en pubspec.yaml (ver README). Si no existe, Flutter usa
/// la fuente por defecto.
const String kFbuFontFamily = 'SpaceGrotesk';

class FbuSplashScreen extends StatefulWidget {
  const FbuSplashScreen({
    super.key,
    required this.onFinished,
    this.waitFor,
    this.logoSize = 260,
  });

  /// Se llama una sola vez cuando termina el fadeOut final.
  final VoidCallback onFinished;

  /// Trabajo de arranque (Firebase, sesión, etc.). La fase 2 dura mínimo
  /// 2.2 s y sigue en bucle hasta que este Future termine (con o sin error).
  final Future<void>? waitFor;

  /// Tamaño del emblema en píxeles lógicos (en el diseño: 260).
  final double logoSize;

  @override
  State<FbuSplashScreen> createState() => _FbuSplashScreenState();
}

class _FbuSplashScreenState extends State<FbuSplashScreen>
    with SingleTickerProviderStateMixin {
  // Tiempos en segundos, iguales al diseño.
  static const double _zoomDur = 0.6;
  static const double _loopMinEnd = 2.8;
  static const double _liftDur = 0.6;
  static const double _lettersDelay = 0.4;
  static const double _lettersDur = 0.6;
  static const double _fadeDelay = 2.0; // 0.4 + 0.6 + 1 s quieto
  static const double _fadeDur = 0.6;

  late final Ticker _ticker;
  double _t = 0;
  bool _ready = false;
  double? _outroStart;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final wait = widget.waitFor;
    if (wait == null) {
      _ready = true;
    } else {
      wait
          .then<void>((_) {}, onError: (Object _) {})
          .whenComplete(() => _ready = true);
    }
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    if (_outroStart == null && _ready && t >= _loopMinEnd) {
      _outroStart = t;
    }
    final start = _outroStart;
    if (!_finished && start != null && t - start >= _fadeDelay + _fadeDur) {
      _finished = true;
      _ticker.stop();
      widget.onFinished();
      return;
    }
    setState(() => _t = t);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  static double _c01(double v) => v.clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final size = widget.logoSize;
    final k = size / 260;

    // 1. ZoomIn
    final zp = _c01(t / _zoomDur);
    final scale = 0.3 + 0.7 * Curves.easeOutBack.transform(zp);
    final logoOpacity = _c01(zp / 0.6);

    // 3. Salida (o < 0 mientras no empieza)
    final o = _outroStart == null ? -1.0 : t - _outroStart!;
    final liftMax = 70 * k;
    final lift = liftMax * Curves.easeInOut.transform(_c01(o / _liftDur));
    final lp = Curves.easeOutCubic
        .transform(_c01((o - _lettersDelay) / _lettersDur));
    final fade = 1 - _c01((o - _fadeDelay) / _fadeDur);

    return Scaffold(
      backgroundColor: FbuColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cy = constraints.maxHeight / 2;
          return Opacity(
            opacity: fade,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: cy - size / 2 - lift,
                  child: Center(
                    child: Opacity(
                      opacity: logoOpacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Semantics(
                          label: 'Financial Between Us',
                          image: true,
                          child: SizedBox.square(
                            dimension: size,
                            child: CustomPaint(
                              painter: _FbuLogoPainter(t: t),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: cy + size / 2 - liftMax + 24 * k,
                  child: Opacity(
                    opacity: lp,
                    child: Transform.translate(
                      offset: Offset(0, 48 * k * (1 - lp)),
                      child: _FbuLetters(scale: k),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FbuLetters extends StatelessWidget {
  const _FbuLetters({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final fs = 64 * scale;
    final style = TextStyle(
      fontFamily: kFbuFontFamily,
      fontSize: fs,
      fontWeight: FontWeight.w700,
      letterSpacing: fs * 0.24,
      height: 1,
      color: FbuColors.white,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          // compensa el espaciado tras la última letra para centrar
          padding: EdgeInsets.only(left: fs * 0.24),
          child: Text.rich(
            TextSpan(
              style: style,
              children: const [
                TextSpan(text: 'F'),
                TextSpan(text: 'B', style: TextStyle(color: FbuColors.green)),
                TextSpan(text: 'U'),
              ],
            ),
            semanticsLabel: 'FBU',
          ),
        ),
        SizedBox(height: 12 * scale),
        Container(
          width: 48 * scale,
          height: 5 * scale,
          decoration: BoxDecoration(
            color: FbuColors.green,
            borderRadius: BorderRadius.circular(3 * scale),
          ),
        ),
      ],
    );
  }
}

/// Dibuja el emblema en un sistema de 400×400 (mismas coordenadas que el SVG).
class _FbuLogoPainter extends CustomPainter {
  _FbuLogoPainter({required this.t});

  final double t;

  static const double _spinStart = 0.6;
  static const double _spinPeriod = 1.2;
  static const double _arrowPeriod = 1.6;
  static const double _arrowADelay = 0.6;
  static const double _arrowBDelay = 1.4;

  static const TextStyle _rimStyle = TextStyle(
    fontFamily: kFbuFontFamily,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: FbuColors.green,
  );

  static final Path _arrowA = Path()
    ..moveTo(140, 148)
    ..quadraticBezierTo(200, 104, 260, 148);
  static final Path _arrowB = Path()
    ..moveTo(260, 272)
    ..quadraticBezierTo(200, 316, 140, 272);
  static final Path _headA = Path()
    ..moveTo(245, 149)
    ..lineTo(262, 150)
    ..lineTo(256, 134);
  static final Path _headB = Path()
    ..moveTo(155, 271)
    ..lineTo(138, 270)
    ..lineTo(144, 286);
  static final Path _bodyL = Path()
    ..moveTo(92, 250)
    ..cubicTo(92, 224, 108, 210, 128, 210)
    ..cubicTo(148, 210, 164, 224, 164, 250)
    ..close();
  static final Path _bodyR = Path()
    ..moveTo(236, 250)
    ..cubicTo(236, 224, 252, 210, 272, 210)
    ..cubicTo(292, 210, 308, 224, 308, 250)
    ..close();
  static final Path _dollarS = Path()
    ..moveTo(209, 206)
    ..cubicTo(207, 201, 193, 200, 192, 207)
    ..cubicTo(191, 213, 209, 214, 208, 221)
    ..cubicTo(207, 228, 193, 228, 191, 222);

  static Path _star(double cx) => Path()
    ..moveTo(cx, 190)
    ..lineTo(cx + 3, 197)
    ..lineTo(cx + 10, 200)
    ..lineTo(cx + 3, 203)
    ..lineTo(cx, 210)
    ..lineTo(cx - 3, 203)
    ..lineTo(cx - 10, 200)
    ..lineTo(cx - 3, 197)
    ..close();

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = color
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static Paint _fill(Color color) => Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 400);
    const center = Offset(200, 200);

    // Moneda exterior
    canvas.drawCircle(center, 194, _fill(FbuColors.coin));
    canvas.drawCircle(center, 194, _stroke(FbuColors.green, 6));
    _drawReeding(canvas);
    canvas.drawCircle(center, 175, _stroke(FbuColors.green, 2));
    canvas.drawCircle(center, 142, _fill(FbuColors.disc));
    canvas.drawCircle(center, 142, _stroke(FbuColors.green, 2));

    _drawRimText(canvas, 'FINANCIAL BETWEEN US');
    canvas.drawPath(_star(42), _fill(FbuColors.green));
    canvas.drawPath(_star(358), _fill(FbuColors.green));

    // Flechas (fase 2, en bucle)
    _drawArrow(canvas, _arrowA, _headA, FbuColors.green, t - _arrowADelay);
    _drawArrow(canvas, _arrowB, _headB, FbuColors.white, t - _arrowBDelay);

    // Personas
    canvas.drawCircle(const Offset(128, 180), 20, _fill(FbuColors.green));
    canvas.drawPath(_bodyL, _fill(FbuColors.green));
    canvas.drawCircle(const Offset(272, 180), 20, _fill(FbuColors.white));
    canvas.drawPath(_bodyR, _fill(FbuColors.white));

    // Moneda "$" girando a la derecha
    final spin = t < _spinStart
        ? 0.0
        : ((t - _spinStart) / _spinPeriod) * 2 * math.pi;
    const coinCenter = Offset(200, 214);
    canvas.save();
    canvas.translate(coinCenter.dx, coinCenter.dy);
    canvas.rotate(spin);
    canvas.translate(-coinCenter.dx, -coinCenter.dy);
    canvas.drawCircle(coinCenter, 25, _fill(FbuColors.coin));
    canvas.drawCircle(coinCenter, 25, _stroke(FbuColors.green, 3));
    canvas.drawLine(
      const Offset(200, 198),
      const Offset(200, 230),
      _stroke(FbuColors.green, 4),
    );
    canvas.drawPath(_dollarS, _stroke(FbuColors.green, 4.5));
    canvas.restore();

    canvas.restore();
  }

  /// Estrías del borde de la moneda.
  void _drawReeding(Canvas canvas) {
    const r = 184.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = FbuColors.reeding
      ..strokeCap = StrokeCap.butt;
    final rect = Rect.fromCircle(center: const Offset(200, 200), radius: r);
    final count = (2 * math.pi * r / 7).floor();
    final step = 2 * math.pi / count;
    const sweep = 2 / r;
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * step, sweep, false, paint);
    }
  }

  /// Texto curvo centrado arriba, con las letras hacia afuera.
  void _drawRimText(Canvas canvas, String text) {
    const r = 152.0;
    const spacing = 4.0;
    final glyphs = [
      for (final ch in text.split(''))
        TextPainter(
          text: TextSpan(text: ch, style: _rimStyle),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final total =
        glyphs.fold<double>(0, (sum, g) => sum + g.width + spacing) - spacing;
    var cursor = -total / 2;
    for (final g in glyphs) {
      final theta = (cursor + g.width / 2) / r; // 0 = arriba, + = derecha
      final baseline =
          g.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      canvas.save();
      canvas.translate(200, 200);
      canvas.rotate(theta);
      canvas.translate(0, -r);
      g.paint(canvas, Offset(-g.width / 2, -baseline));
      canvas.restore();
      cursor += g.width + spacing;
      g.dispose();
    }
  }

  /// Dibuja la flecha de la cola a la punta y la borra en el mismo orden.
  void _drawArrow(
    Canvas canvas,
    Path path,
    Path head,
    Color color,
    double local,
  ) {
    if (local < 0) return;
    final p = (local % _arrowPeriod) / _arrowPeriod;

    double start;
    double end;
    if (p < 0.45) {
      start = 0;
      end = Curves.easeInOut.transform(p / 0.45);
    } else if (p < 0.55) {
      start = 0;
      end = 1;
    } else {
      start = Curves.easeInOut.transform((p - 0.55) / 0.45);
      end = 1;
    }

    double opacity;
    if (p < 0.12) {
      opacity = p / 0.12;
    } else if (p < 0.55) {
      opacity = 1;
    } else {
      opacity = 1 - (p - 0.55) / 0.45;
    }

    final metric = path.computeMetrics().first;
    if (end > start && opacity > 0) {
      canvas.drawPath(
        metric.extractPath(metric.length * start, metric.length * end),
        _stroke(color.withAlpha((255 * opacity).round()), 5),
      );
    }

    double headOpacity;
    if (p < 0.40) {
      headOpacity = 0;
    } else if (p < 0.48) {
      headOpacity = (p - 0.40) / 0.08;
    } else if (p < 0.62) {
      headOpacity = 1;
    } else if (p < 0.92) {
      headOpacity = 1 - (p - 0.62) / 0.30;
    } else {
      headOpacity = 0;
    }
    if (headOpacity > 0) {
      canvas.drawPath(
        head,
        _stroke(color.withAlpha((255 * headOpacity).round()), 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FbuLogoPainter oldDelegate) =>
      oldDelegate.t != t;
}
