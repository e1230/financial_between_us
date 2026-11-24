import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/branding/fbu_emblem.dart';
import '../../../core/branding/fbu_emblem_geometry.dart';
import '../../../core/branding/fbu_wordmark.dart';
import '../../../core/theme/app_tokens.dart';
import 'splash_timeline.dart';

/// Animated splash of Financial Between Us (pure Flutter, no packages):
///
/// 1. 0.0 – 0.6 s: zoom-in of the emblem on black.
/// 2. 0.6 – 2.8 s: the "$" spins clockwise and the arrows are drawn from tail
///    to tip and erased in the same order. Keeps looping while [ready] is
///    false.
/// 3. Outro: the emblem rises, "FBU" slides in from below, holds for 1 s and
///    everything fades out. Then [onFinished] is called once.
///
/// With `MediaQuery.disableAnimations`, it shows the final logo statically and
/// calls [onFinished] as soon as [ready] is true (after a short hold).
class FbuSplashAnimation extends StatefulWidget {
  const FbuSplashAnimation({
    super.key,
    required this.ready,
    required this.onFinished,
    this.logoSize = FbuLogoMetrics.designEmblemSize,
  });

  /// Whether app startup has completed and the splash may finish.
  final bool ready;

  /// Called once when the splash finishes.
  final VoidCallback onFinished;

  /// Emblem size in logical pixels.
  final double logoSize;

  @override
  State<FbuSplashAnimation> createState() => _FbuSplashAnimationState();
}

class _FbuSplashAnimationState extends State<FbuSplashAnimation>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  bool _reducedMotion = false;
  double _t = 0;
  double? _outroStart;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;

    if (_reducedMotion) {
      if (widget.ready && t >= SplashTimeline.reducedMotionHold) _finish();
      return;
    }

    if (_outroStart == null && widget.ready && t >= SplashTimeline.minLoopEnd) {
      _outroStart = t;
    }
    final outroStart = _outroStart;
    if (outroStart != null &&
        t - outroStart >= SplashTimeline.fadeDelay + SplashTimeline.fadeOut) {
      _finish();
      return;
    }
    setState(() => _t = t);
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _ticker.stop();
    widget.onFinished();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final frame = _reducedMotion
        ? const SplashFrame.still()
        : SplashFrame.at(_t, _outroStart);

    final size = widget.logoSize;
    final k = FbuLogoMetrics.scaleFor(size);
    final liftMax = FbuLogoMetrics.splashLift * k;

    return Scaffold(
      backgroundColor: tokens.brandBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cy = constraints.maxHeight / 2;
          return Opacity(
            opacity: frame.opacity,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: cy - size / 2 - liftMax * frame.lift,
                  child: Center(
                    child: Opacity(
                      opacity: frame.emblemOpacity,
                      child: Transform.scale(
                        scale: frame.emblemScale,
                        child: FbuEmblem(
                          size: size,
                          coinAngle: frame.coinAngle,
                          arrowA: frame.arrowA,
                          arrowB: frame.arrowB,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top:
                      cy +
                      size / 2 -
                      liftMax +
                      FbuLogoMetrics.emblemToWordmarkGap * k,
                  child: Opacity(
                    opacity: frame.wordmark,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        FbuLogoMetrics.splashWordmarkSlide *
                            k *
                            (1 - frame.wordmark),
                      ),
                      child: FbuWordmark(emblemSize: size),
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
