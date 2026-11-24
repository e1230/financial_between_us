import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../auth_metrics.dart';

/// Green check inside a 64 dp circle (accent at 12 %).
///
/// The circle grows 0.6 → 1 with `easeOutBack` (400 ms) and, 150 ms later,
/// the check draws itself from start to end (300 ms). With
/// `MediaQuery.disableAnimations` it appears complete.
class SuccessCheck extends StatefulWidget {
  const SuccessCheck({super.key});

  @override
  State<SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<SuccessCheck>
    with SingleTickerProviderStateMixin {
  static final Duration _total =
      AuthMetrics.checkDrawDelay + AuthMetrics.checkDrawDuration;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total > AuthMetrics.checkCircleDuration
        ? _total
        : AuthMetrics.checkCircleDuration,
  );

  late final Animation<double> _circle =
      Tween<double>(begin: AuthMetrics.checkCircleStartScale, end: 1).animate(
        _interval(
          Duration.zero,
          AuthMetrics.checkCircleDuration,
          Curves.easeOutBack,
        ),
      );

  late final Animation<double> _draw = _interval(
    AuthMetrics.checkDrawDelay,
    AuthMetrics.checkDrawDuration,
    Curves.easeOut,
  );

  CurvedAnimation _interval(Duration start, Duration length, Curve curve) {
    final total = _controller.duration!.inMicroseconds;
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        start.inMicroseconds / total,
        (start + length).inMicroseconds / total,
        curve: curve,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: ScaleTransition(
        scale: _circle,
        child: Container(
          width: AuthMetrics.checkCircleSize,
          height: AuthMetrics.checkCircleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tokens.accent.withValues(
              alpha: AuthMetrics.checkCircleOpacity,
            ),
          ),
          alignment: Alignment.center,
          child: CustomPaint(
            size: const Size.square(AuthMetrics.checkIconSize),
            painter: _CheckPainter(progress: _draw, color: tokens.accent),
          ),
        ),
      ),
    );
  }
}

/// Draws the first [progress] of a check mark (Material "check" geometry).
class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color})
    : super(repaint: progress);

  final Animation<double> progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.53)
      ..lineTo(size.width * 0.39, size.height * 0.76)
      ..lineTo(size.width * 0.84, size.height * 0.29);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = AuthMetrics.checkStroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * progress.value;
    for (final metric in metrics) {
      if (remaining <= 0) break;
      canvas.drawPath(metric.extractPath(0, remaining), paint);
      remaining -= metric.length;
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
