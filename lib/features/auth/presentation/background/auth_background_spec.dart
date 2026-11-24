import 'dart:math' as math;
import 'dart:ui' show Offset, Size, lerpDouble;

import 'package:flutter/animation.dart';

/// Background look of each auth screen.
enum AuthBackgroundVariant {
  /// Welcome: the glow group untransformed.
  welcome,

  /// Forms (sign-up, login, recover, sent, choose username): the glow group
  /// shrunk towards the top-left and dimmed.
  form,
}

/// Color roles of the glow gradients, resolved against `AppTokens`.
enum GlowTone { bright, mid, deep, teal, base }

/// One stop of a radial glow gradient.
class GlowStop {
  const GlowStop(this.position, this.tone, this.alpha);

  /// 0 (center) to 1 (edge of the ellipse).
  final double position;
  final GlowTone tone;
  final double alpha;
}

/// Transform of a glow layer at a point of its cycle. Translations are
/// fractions of the screen (width for [dx], height for [dy]); scale and
/// [rotation] (radians) apply around the layer center.
class LayerPose {
  const LayerPose({
    this.dx = 0,
    this.dy = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.rotation = 0,
  });

  final double dx;
  final double dy;
  final double scaleX;
  final double scaleY;
  final double rotation;

  static LayerPose lerp(LayerPose a, LayerPose b, double t) => LayerPose(
    dx: lerpDouble(a.dx, b.dx, t)!,
    dy: lerpDouble(a.dy, b.dy, t)!,
    scaleX: lerpDouble(a.scaleX, b.scaleX, t)!,
    scaleY: lerpDouble(a.scaleY, b.scaleY, t)!,
    rotation: lerpDouble(a.rotation, b.rotation, t)!,
  );

  /// This pose with its translation and scale [factor] times farther from
  /// rest (rotation unchanged). Used to make the drift more noticeable.
  LayerPose amplified(double factor) => LayerPose(
    dx: dx * factor,
    dy: dy * factor,
    scaleX: 1 + (scaleX - 1) * factor,
    scaleY: 1 + (scaleY - 1) * factor,
    rotation: rotation,
  );

  @override
  String toString() =>
      'LayerPose(dx: $dx, dy: $dy, scale: $scaleX×$scaleY, rot: $rotation)';
}

/// A [LayerPose] at a fraction [at] (0–1) of the layer cycle.
class LayerKeyframe {
  const LayerKeyframe(this.at, this.pose);

  final double at;
  final LayerPose pose;
}

/// Shape, gradient and motion of one elliptical glow layer.
class GlowLayerSpec {
  const GlowLayerSpec({
    required this.name,
    required this.size,
    required this.center,
    required this.stops,
    required this.cycleSeconds,
    required this.keyframes,
  });

  final String name;

  /// Ellipse size as a fraction of the screen.
  final Size size;

  /// Ellipse center as a fraction of the screen.
  final Offset center;
  final List<GlowStop> stops;
  final double cycleSeconds;

  /// Sorted by [LayerKeyframe.at], from 0 to 1. Every segment between two
  /// keyframes is eased with [AuthBackgroundSpec.curve].
  final List<LayerKeyframe> keyframes;

  /// Pose of the layer [seconds] after the background started.
  LayerPose poseAt(double seconds) {
    final phase = (seconds % cycleSeconds) / cycleSeconds;
    for (var i = 0; i < keyframes.length - 1; i++) {
      final from = keyframes[i];
      final to = keyframes[i + 1];
      if (phase <= to.at) {
        final local = (phase - from.at) / (to.at - from.at);
        return LayerPose.lerp(
          from.pose,
          to.pose,
          AuthBackgroundSpec.curve.transform(local.clamp(0, 1)),
        );
      }
    }
    return keyframes.last.pose;
  }
}

/// Transform applied to the whole glow group by the variant (the mask is not
/// transformed). [dx]/[dy] are fractions of the screen; [scale] applies
/// around [AuthBackgroundSpec.variantOrigin].
class GlowGroupTransform {
  const GlowGroupTransform({
    required this.scale,
    required this.dx,
    required this.dy,
    required this.opacity,
  });

  final double scale;
  final double dx;
  final double dy;
  final double opacity;

  /// [t] = 0 is [AuthBackgroundVariant.welcome], 1 is
  /// [AuthBackgroundVariant.form].
  static GlowGroupTransform lerp(double t) {
    const a = AuthBackgroundSpec.welcomeTransform;
    const b = AuthBackgroundSpec.formTransform;
    return GlowGroupTransform(
      scale: lerpDouble(a.scale, b.scale, t)!,
      dx: lerpDouble(a.dx, b.dx, t)!,
      dy: lerpDouble(a.dy, b.dy, t)!,
      opacity: lerpDouble(a.opacity, b.opacity, t)!,
    );
  }
}

double _deg(double degrees) => degrees * math.pi / 180;

/// Values of the animated auth background (design 360×800, expressed as
/// fractions of the screen so they scale to any size).
abstract final class AuthBackgroundSpec {
  /// Easing of every keyframe segment and of the breathing: easeInOutSine
  /// as the CSS reference defines it, `cubic-bezier(.37, 0, .63, 1)`.
  /// (Flutter's `Curves.easeInOutSine` is a slightly different
  /// approximation.)
  static const Curve curve = Cubic(0.37, 0, 0.63, 1);

  // Layers, in paint order: core → teal → wave B → wave A.

  static final GlowLayerSpec core = GlowLayerSpec(
    name: 'core',
    size: const Size(1.30, 0.62),
    center: const Offset(0.40, 0.16),
    stops: const [
      GlowStop(0, GlowTone.bright, 0.42),
      GlowStop(0.38, GlowTone.mid, 0.62),
      GlowStop(0.68, GlowTone.deep, 0.70),
      GlowStop(1, GlowTone.base, 0),
    ],
    cycleSeconds: 16,
    keyframes: const [
      LayerKeyframe(0, LayerPose()),
      LayerKeyframe(
        0.25,
        LayerPose(dx: 0.0325, dy: 0.0062, scaleX: 1.14, scaleY: 0.92),
      ),
      LayerKeyframe(
        0.5,
        LayerPose(dx: 0.065, dy: 0.0248, scaleX: 1.04, scaleY: 1.16),
      ),
      LayerKeyframe(
        0.75,
        LayerPose(dx: 0.026, dy: 0.0155, scaleX: 0.90, scaleY: 1.06),
      ),
      LayerKeyframe(1, LayerPose()),
    ],
  );

  static final GlowLayerSpec teal = GlowLayerSpec(
    name: 'teal',
    size: const Size(0.70, 0.34),
    center: const Offset(0.90, 0.11),
    stops: const [
      GlowStop(0, GlowTone.teal, 0.75),
      GlowStop(0.5, GlowTone.teal, 0.35),
      GlowStop(1, GlowTone.teal, 0),
    ],
    cycleSeconds: 23,
    keyframes: const [
      LayerKeyframe(0, LayerPose()),
      LayerKeyframe(0.5, LayerPose(dx: -0.063, dy: 0.0102)),
      LayerKeyframe(1, LayerPose()),
    ],
  );

  static final GlowLayerSpec waveB = GlowLayerSpec(
    name: 'waveB',
    size: const Size(1.50, 0.20),
    center: const Offset(0.55, 0.28),
    stops: const [
      GlowStop(0, GlowTone.mid, 0.30),
      GlowStop(1, GlowTone.mid, 0),
    ],
    cycleSeconds: 25,
    keyframes: [
      LayerKeyframe(0, LayerPose(dx: 0.0375, rotation: _deg(6))),
      LayerKeyframe(0.5, LayerPose(dx: -0.0375, dy: -0.004, rotation: _deg(3))),
      LayerKeyframe(1, LayerPose(dx: 0.0375, rotation: _deg(6))),
    ],
  );

  static final GlowLayerSpec waveA = GlowLayerSpec(
    name: 'waveA',
    size: const Size(1.60, 0.26),
    center: const Offset(0.50, 0.15),
    stops: const [
      GlowStop(0, GlowTone.bright, 0.22),
      GlowStop(0.55, GlowTone.mid, 0.12),
      GlowStop(1, GlowTone.mid, 0),
    ],
    cycleSeconds: 17,
    keyframes: [
      LayerKeyframe(0, LayerPose(dx: -0.04, rotation: _deg(-8))),
      LayerKeyframe(0.5, LayerPose(dx: 0.04, dy: 0.0052, rotation: _deg(-5))),
      LayerKeyframe(1, LayerPose(dx: -0.04, rotation: _deg(-8))),
    ],
  );

  static final List<GlowLayerSpec> layers = [core, teal, waveB, waveA];

  // DECISIÓN: the handoff values move too little and too slowly to be
  // noticed on a phone, so the whole animation plays [speed] times faster
  // (core 8 s, waves 8.5–12.5 s, breathing 4 s) and the translations and
  // scales of every layer are [amplitude] times larger. Set both to 1 to
  // get exactly the reference preview.

  /// Playback speed of every layer and of the breathing.
  static const double speed = 2;

  /// Multiplier of the layer translations and scales.
  static const double amplitude = 1.5;

  // Breathing: brightness of the whole group, 0.9 → 1.1 → 0.9.
  static const double breathSeconds = 8;
  static const double breathMin = 0.9;
  static const double breathMax = 1.1;

  /// Brightness factor [seconds] after the background started.
  static double breathFactor(double seconds) {
    final phase = (seconds % breathSeconds) / breathSeconds;
    final half = phase <= 0.5 ? phase * 2 : (1 - phase) * 2;
    return lerpDouble(breathMin, breathMax, curve.transform(half))!;
  }

  // Vertical mask (alpha by screen position): solid at the top, gone at 45 %.
  static const List<double> maskAlphas = [1, 1, 0.5, 0];
  static const List<double> maskStops = [0, 0.22, 0.34, 0.45];

  // Variants.
  static const Offset variantOrigin = Offset(0.38, 0.18);
  static const GlowGroupTransform welcomeTransform = GlowGroupTransform(
    scale: 1,
    dx: 0,
    dy: 0,
    opacity: 1,
  );
  static const GlowGroupTransform formTransform = GlowGroupTransform(
    scale: 0.72,
    dx: -0.06,
    dy: -0.08,
    opacity: 0.6,
  );
  static const Duration variantDuration = Duration(milliseconds: 600);
  static const Duration variantDurationReducedMotion = Duration(
    milliseconds: 200,
  );
  static const Curve variantCurve = Curves.fastOutSlowIn;

  // Film grain on top of the glows.
  static const String grainAsset = 'assets/images/auth/grano_256.png';
  static const double grainOpacity = 0.03;
}
