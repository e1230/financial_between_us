import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/accent_color.dart';
import '../profile_metrics.dart';
import '../profile_strings.dart';

/// Saturation (x) and brightness (y) of a hue. Shades that are not readable
/// with `#111111` text are covered and cannot be selected: a drag into them
/// snaps to the closest readable shade.
class ShadeArea extends StatelessWidget {
  const ShadeArea({super.key, required this.color, required this.onChanged});

  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;

  static const double _semanticStep = 0.05;

  void _select(Offset position, Size size) {
    final saturation = (position.dx / size.width).clamp(0.0, 1.0);
    final value = 1 - (position.dy / size.height).clamp(0.0, 1.0);
    onChanged(
      AccentColor.makeReadable(
        HSVColor.fromAHSV(1, color.hue, saturation, value),
      ),
    );
  }

  HSVColor _nudged(double delta) => AccentColor.makeReadable(
    color.withValue((color.value + delta).clamp(0.0, 1.0)),
  );

  static String _describe(HSVColor color) =>
      AccentColor.toHex(color.toColor().toARGB32());

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      slider: true,
      label: ProfileStrings.shade,
      value: _describe(color),
      increasedValue: _describe(_nudged(_semanticStep)),
      decreasedValue: _describe(_nudged(-_semanticStep)),
      onIncrease: () => onChanged(_nudged(_semanticStep)),
      onDecrease: () => onChanged(_nudged(-_semanticStep)),
      child: SizedBox(
        height: ProfileMetrics.shadeAreaHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (details) => _select(details.localPosition, size),
              onPanUpdate: (details) => _select(details.localPosition, size),
              child: CustomPaint(
                size: size,
                painter: _ShadePainter(
                  color: color,
                  radius: tokens.radiusInput,
                  cover: tokens.background.withValues(
                    alpha: ProfileMetrics.unreadableCoverOpacity,
                  ),
                  thumbBorder: tokens.textPrimary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ShadePainter extends CustomPainter {
  _ShadePainter({
    required this.color,
    required this.radius,
    required this.cover,
    required this.thumbBorder,
  });

  final HSVColor color;
  final double radius;
  final Color cover;
  final Color thumbBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hue = color.hue;
    canvas
      ..save()
      ..clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    // Saturation: white → pure hue.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            HSVColor.fromAHSV(1, hue, 0, 1).toColor(),
            HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
          ],
        ).createShader(rect),
    );
    // Brightness: transparent → black.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            HSVColor.fromAHSV(0, hue, 0, 0).toColor(),
            HSVColor.fromAHSV(1, hue, 0, 0).toColor(),
          ],
        ).createShader(rect),
    );

    // Cover below the readable boundary.
    final boundary = Path()..moveTo(0, size.height);
    const samples = ProfileMetrics.boundarySamples;
    for (var i = 0; i <= samples; i++) {
      final saturation = i / samples;
      final minValue = AccentColor.minReadableValue(hue, saturation) ?? 1;
      boundary.lineTo(saturation * size.width, (1 - minValue) * size.height);
    }
    boundary
      ..lineTo(size.width, size.height)
      ..close();
    canvas
      ..drawPath(boundary, Paint()..color = cover)
      ..restore();

    _paintThumb(
      canvas,
      Offset(color.saturation * size.width, (1 - color.value) * size.height),
      color.toColor(),
      thumbBorder,
    );
  }

  @override
  bool shouldRepaint(_ShadePainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.cover != cover ||
      old.thumbBorder != thumbBorder;
}

/// Hue bar (0–360°). Changing the hue keeps the shade, adjusted to stay
/// readable.
class HueBar extends StatelessWidget {
  const HueBar({super.key, required this.color, required this.onChanged});

  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;

  static const double _semanticStep = 10;

  void _select(double dx, double width) => onChanged(
    AccentColor.makeReadable(
      color.withHue((dx / width).clamp(0.0, 1.0) * 360 % 360),
    ),
  );

  HSVColor _nudged(double delta) =>
      AccentColor.makeReadable(color.withHue((color.hue + delta) % 360));

  static String _describe(HSVColor color) => '${color.hue.round()}°';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      slider: true,
      label: ProfileStrings.hue,
      value: _describe(color),
      increasedValue: _describe(_nudged(_semanticStep)),
      decreasedValue: _describe(_nudged(360 - _semanticStep)),
      onIncrease: () => onChanged(_nudged(_semanticStep)),
      onDecrease: () => onChanged(_nudged(360 - _semanticStep)),
      child: SizedBox(
        // Taller than the bar so it is easy to grab.
        height: ProfileMetrics.thumbSize + tokens.space2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanDown: (d) => _select(d.localPosition.dx, size.width),
              onPanUpdate: (d) => _select(d.localPosition.dx, size.width),
              child: CustomPaint(
                size: size,
                painter: _HuePainter(
                  color: color,
                  radius: tokens.radiusPill,
                  thumbBorder: tokens.textPrimary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HuePainter extends CustomPainter {
  _HuePainter({
    required this.color,
    required this.radius,
    required this.thumbBorder,
  });

  final HSVColor color;
  final double radius;
  final Color thumbBorder;

  @override
  void paint(Canvas canvas, Size size) {
    const stops = ProfileMetrics.hueStops;
    final bar = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width,
      height: ProfileMetrics.hueBarHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, Radius.circular(radius)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            for (var i = 0; i < stops; i++)
              HSVColor.fromAHSV(1, i * 360 / (stops - 1) % 360, 1, 1).toColor(),
          ],
        ).createShader(bar),
    );
    _paintThumb(
      canvas,
      Offset(color.hue / 360 * size.width, size.height / 2),
      HSVColor.fromAHSV(1, color.hue, 1, 1).toColor(),
      thumbBorder,
    );
  }

  @override
  bool shouldRepaint(_HuePainter old) =>
      old.color.hue != color.hue ||
      old.radius != radius ||
      old.thumbBorder != thumbBorder;
}

void _paintThumb(Canvas canvas, Offset center, Color fill, Color border) {
  const radius = ProfileMetrics.thumbSize / 2;
  canvas
    ..drawCircle(center, radius, Paint()..color = fill)
    ..drawCircle(
      center,
      radius - ProfileMetrics.thumbBorder / 2,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = ProfileMetrics.thumbBorder,
    );
}
