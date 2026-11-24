import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../../../core/branding/arrow_frame.dart';

/// Timeline of the splash animation, in seconds.
abstract final class SplashTimeline {
  /// Phase 1: zoom-in of the emblem.
  static const double zoomIn = 0.6;

  /// Phase 2 (looping "$" spin and arrows) lasts at least until this moment,
  /// and keeps looping while the app is not ready.
  static const double minLoopEnd = 2.8;

  // Phase 3 (outro), relative to its start.
  static const double lift = 0.6;
  static const double wordmarkDelay = 0.4;
  static const double wordmarkIn = 0.6;
  static const double fadeDelay = 2.0; // wordmark in + 1 s still
  static const double fadeOut = 0.6;

  // Emblem loops.
  static const double spinStart = 0.6;
  static const double spinPeriod = 1.2;
  static const double arrowPeriod = 1.6;
  static const double arrowADelay = 0.6;
  static const double arrowBDelay = 1.4;

  /// Shortest possible splash when the app is ready from the start.
  static const double minTotal = minLoopEnd + fadeDelay + fadeOut;

  /// Time the static logo stays on screen when animations are disabled.
  static const double reducedMotionHold = 1.0;
}

double _unit(double v) => v.clamp(0.0, 1.0);

/// Visual state of the splash at a given moment. Pure, so it is easy to test.
@immutable
class SplashFrame {
  const SplashFrame({
    required this.emblemScale,
    required this.emblemOpacity,
    required this.coinAngle,
    required this.arrowA,
    required this.arrowB,
    required this.lift,
    required this.wordmark,
    required this.opacity,
  });

  /// Final layout without motion (reduced-motion mode).
  const SplashFrame.still()
    : emblemScale = 1,
      emblemOpacity = 1,
      coinAngle = 0,
      arrowA = ArrowFrame.complete,
      arrowB = ArrowFrame.complete,
      lift = 1,
      wordmark = 1,
      opacity = 1;

  factory SplashFrame.at(double t, double? outroStart) {
    // 1. Zoom-in
    final zoom = _unit(t / SplashTimeline.zoomIn);

    // 2. Loops
    final spin = t < SplashTimeline.spinStart
        ? 0.0
        : (t - SplashTimeline.spinStart) / SplashTimeline.spinPeriod;

    // 3. Outro (negative while it has not started)
    final o = outroStart == null ? -1.0 : t - outroStart;

    return SplashFrame(
      emblemScale: 0.3 + 0.7 * Curves.easeOutBack.transform(zoom),
      emblemOpacity: _unit(zoom / 0.6),
      coinAngle: spin * 2 * math.pi,
      arrowA: ArrowFrame.looping(
        elapsed: t - SplashTimeline.arrowADelay,
        period: SplashTimeline.arrowPeriod,
      ),
      arrowB: ArrowFrame.looping(
        elapsed: t - SplashTimeline.arrowBDelay,
        period: SplashTimeline.arrowPeriod,
      ),
      lift: Curves.easeInOut.transform(_unit(o / SplashTimeline.lift)),
      wordmark: Curves.easeOutCubic.transform(
        _unit((o - SplashTimeline.wordmarkDelay) / SplashTimeline.wordmarkIn),
      ),
      opacity:
          1 - _unit((o - SplashTimeline.fadeDelay) / SplashTimeline.fadeOut),
    );
  }

  final double emblemScale;
  final double emblemOpacity;
  final double coinAngle;
  final ArrowFrame arrowA;
  final ArrowFrame arrowB;

  /// Emblem rise progress (0..1).
  final double lift;

  /// Wordmark entrance progress (0..1).
  final double wordmark;

  /// Global opacity (final fade-out).
  final double opacity;
}
