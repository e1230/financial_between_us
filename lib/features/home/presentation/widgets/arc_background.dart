import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import 'arc_painter.dart';

/// Full-screen, static arc behind the Home ([ArcPainter]). Its center takes
/// the user's color, which the theme animates when it changes.
class ArcBackground extends StatelessWidget {
  const ArcBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: ArcPainter(
            ArcColors(
              center: palette.userColor,
              tint: palette.userTint,
              green: tokens.glowBright,
              teal: tokens.glowTeal,
              cutTop: tokens.arcCutTop,
              cutBottom: tokens.arcCutBottom,
            ),
          ),
        ),
      ),
    );
  }
}
