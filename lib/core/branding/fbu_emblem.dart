import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'arrow_frame.dart';
import 'fbu_emblem_geometry.dart';
import 'fbu_emblem_painter.dart';

/// The circular FBU emblem (coin with two people exchanging money).
///
/// Static by default; the splash drives [coinAngle], [arrowA] and [arrowB] to
/// animate it.
class FbuEmblem extends StatelessWidget {
  const FbuEmblem({
    super.key,
    this.size = FbuLogoMetrics.designEmblemSize,
    this.coinAngle = 0,
    this.arrowA = ArrowFrame.complete,
    this.arrowB = ArrowFrame.complete,
  });

  final double size;
  final double coinAngle;
  final ArrowFrame arrowA;
  final ArrowFrame arrowB;

  @override
  Widget build(BuildContext context) {
    final palette = FbuEmblemPalette.fromTokens(context.tokens);
    return Semantics(
      label: 'Financial Between Us',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                painter: FbuEmblemBasePainter(palette: palette),
              ),
            ),
            CustomPaint(
              painter: FbuEmblemMotionPainter(
                palette: palette,
                coinAngle: coinAngle,
                arrowA: arrowA,
                arrowB: arrowB,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
