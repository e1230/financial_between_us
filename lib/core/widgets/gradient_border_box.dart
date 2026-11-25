import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../theme/user_palette.dart';

/// A box with a gradient border, like the cards of the Firebase console:
/// an outer box painted with [gradient] and an inner one with [fill],
/// inset by [borderWidth].
///
/// [borderWidth] changes are animated over [duration].
class GradientBorderBox extends StatelessWidget {
  const GradientBorderBox({
    super.key,
    required this.gradient,
    required this.fill,
    required this.child,
    this.borderRadius,
    this.borderWidth = defaultBorderWidth,
    this.duration = Duration.zero,
  });

  /// The 135° brand border: the user's color, the brand green at 55 % and
  /// the brand teal.
  static LinearGradient brandGradient(BuildContext context) {
    final tokens = context.tokens;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        context.userPalette.userColor,
        tokens.glowBright,
        tokens.glowTeal,
      ],
      stops: const [0, brandMidStop, 1],
    );
  }

  static const double defaultBorderWidth = 1.5;

  /// Position of the brand green in [brandGradient].
  static const double brandMidStop = 0.55;

  final Gradient gradient;
  final Color fill;
  final Widget child;

  /// Outer radius; `null` draws a circle.
  final double? borderRadius;
  final double borderWidth;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius;
    final inner = radius == null
        ? null
        : BorderRadius.circular((radius - borderWidth).clamp(0, radius));
    return AnimatedContainer(
      duration: duration,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        gradient: gradient,
        shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius == null ? null : BorderRadius.circular(radius),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: inner,
        ),
        child: child,
      ),
    );
  }
}
