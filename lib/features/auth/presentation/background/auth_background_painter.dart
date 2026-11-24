import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import 'auth_background_spec.dart';

/// Paints the four glow layers of the auth background, transformed by the
/// variant and cut by the vertical mask.
///
/// Repaints from [time] (seconds) and [variant] (0 = welcome, 1 = form)
/// without rebuilding any widget.
class AuthBackgroundPainter extends CustomPainter {
  AuthBackgroundPainter({
    required this.time,
    required this.variant,
    required this.tokens,
    required this.breathing,
  }) : super(repaint: Listenable.merge([time, variant]));

  final ValueListenable<double> time;
  final ValueListenable<double> variant;
  final AppTokens tokens;

  /// Whether the brightness breathes (false with reduced motion: factor 1).
  final bool breathing;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final seconds = time.value;
    final group = GlowGroupTransform.lerp(variant.value);
    final brightness = breathing
        ? AuthBackgroundSpec.breathFactor(seconds)
        : 1.0;

    canvas.saveLayer(bounds, Paint());

    // Group transform: translate + scale around the variant origin.
    final origin = Offset(
      AuthBackgroundSpec.variantOrigin.dx * size.width,
      AuthBackgroundSpec.variantOrigin.dy * size.height,
    );
    canvas
      ..save()
      ..translate(
        origin.dx + group.dx * size.width,
        origin.dy + group.dy * size.height,
      )
      ..scale(group.scale)
      ..translate(-origin.dx, -origin.dy);
    for (final layer in AuthBackgroundSpec.layers) {
      _paintLayer(
        canvas,
        size,
        layer,
        layer.poseAt(seconds).amplified(AuthBackgroundSpec.amplitude),
        brightness,
      );
    }
    canvas.restore();

    // The mask is not transformed. The group opacity is folded into it: both
    // multiply the composited glows, so this saves a second layer.
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Only the alpha of a dstIn mask matters.
          colors: [
            for (final alpha in AuthBackgroundSpec.maskAlphas)
              tokens.background.withValues(alpha: alpha * group.opacity),
          ],
          stops: AuthBackgroundSpec.maskStops,
        ).createShader(bounds),
    );
    canvas.restore();
  }

  /// Draws an elliptical radial gradient ("closest-side"): a unit circle
  /// scaled to the half-axes of the ellipse.
  void _paintLayer(
    Canvas canvas,
    Size size,
    GlowLayerSpec layer,
    LayerPose pose,
    double brightness,
  ) {
    canvas
      ..save()
      ..translate(
        (layer.center.dx + pose.dx) * size.width,
        (layer.center.dy + pose.dy) * size.height,
      )
      ..rotate(pose.rotation)
      ..scale(pose.scaleX, pose.scaleY)
      ..scale(
        layer.size.width * size.width / 2,
        layer.size.height * size.height / 2,
      );

    const unit = Rect.fromLTRB(-1, -1, 1, 1);
    canvas.drawCircle(
      Offset.zero,
      1,
      Paint()
        ..shader = RadialGradient(
          colors: [
            for (final stop in layer.stops) _stopColor(stop, brightness),
          ],
          stops: [for (final stop in layer.stops) stop.position],
        ).createShader(unit),
    );
    canvas.restore();
  }

  // DECISIÓN: the breathing scales the RGB channels (capped at 1) instead of
  // the alpha. That is exactly what `filter: brightness()` does in the
  // reference preview (fondo_animado_preview.html).
  Color _stopColor(GlowStop stop, double brightness) {
    final base = switch (stop.tone) {
      GlowTone.bright => tokens.glowBright,
      GlowTone.mid => tokens.glowMid,
      GlowTone.deep => tokens.glowDeep,
      GlowTone.teal => tokens.glowTeal,
      GlowTone.base => tokens.background,
    };
    return Color.from(
      alpha: stop.alpha,
      red: math.min(1, base.r * brightness),
      green: math.min(1, base.g * brightness),
      blue: math.min(1, base.b * brightness),
    );
  }

  @override
  bool shouldRepaint(AuthBackgroundPainter oldDelegate) =>
      oldDelegate.time != time ||
      oldDelegate.variant != variant ||
      oldDelegate.tokens != tokens ||
      oldDelegate.breathing != breathing;
}
