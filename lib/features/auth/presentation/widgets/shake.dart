import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../auth_metrics.dart';

/// Shakes [child] horizontally (±6 dp, 3 oscillations, 300 ms) when
/// [ShakeState.shake] is called through a `GlobalKey<ShakeState>`.
///
/// Does nothing with `MediaQuery.disableAnimations`.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.child});

  final Widget child;

  @override
  State<Shake> createState() => ShakeState();
}

class ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AuthMetrics.shakeDuration,
  );

  /// Plays the shake from the start.
  void shake() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx =
            math.sin(t * AuthMetrics.shakeOscillations * 2 * math.pi) *
            AuthMetrics.shakeOffset;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
