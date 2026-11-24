import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Drawing state of one emblem arrow: which part of the stroke is visible
/// (`start`..`end`, as fractions of its length) and the opacity of the stroke
/// and of its head.
@immutable
class ArrowFrame {
  const ArrowFrame({
    required this.start,
    required this.end,
    required this.opacity,
    required this.headOpacity,
  });

  /// Fully drawn arrow (static logo).
  static const ArrowFrame complete = ArrowFrame(
    start: 0,
    end: 1,
    opacity: 1,
    headOpacity: 1,
  );

  /// Invisible arrow.
  static const ArrowFrame hidden = ArrowFrame(
    start: 0,
    end: 0,
    opacity: 0,
    headOpacity: 0,
  );

  /// Arrow at the end of a loop: erased from tail to tip.
  static const ArrowFrame erased = ArrowFrame(
    start: 1,
    end: 1,
    opacity: 0,
    headOpacity: 0,
  );

  /// Frame at [phase] (0..1) of one loop: the stroke is drawn from tail to
  /// tip, held briefly, then erased in the same direction while fading out.
  factory ArrowFrame.atPhase(double phase) {
    final p = phase.clamp(0.0, 1.0);
    // Exact end of the loop: fully erased (avoids float/curve residue).
    if (p >= 1) return erased;

    final double start;
    final double end;
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

    final double opacity;
    if (p < 0.12) {
      opacity = p / 0.12;
    } else if (p < 0.55) {
      opacity = 1;
    } else {
      opacity = 1 - (p - 0.55) / 0.45;
    }

    final double headOpacity;
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

    return ArrowFrame(
      start: start,
      end: end,
      opacity: opacity,
      headOpacity: headOpacity,
    );
  }

  /// Frame of a looping arrow [elapsed] seconds after it started, with a loop
  /// of [period] seconds. Hidden before it starts.
  factory ArrowFrame.looping({
    required double elapsed,
    required double period,
  }) {
    if (elapsed < 0) return hidden;
    return ArrowFrame.atPhase((elapsed % period) / period);
  }

  final double start;
  final double end;
  final double opacity;
  final double headOpacity;

  bool get isStrokeVisible => end > start && opacity > 0;

  @override
  bool operator ==(Object other) =>
      other is ArrowFrame &&
      other.start == start &&
      other.end == end &&
      other.opacity == opacity &&
      other.headOpacity == headOpacity;

  @override
  int get hashCode => Object.hash(start, end, opacity, headOpacity);
}
