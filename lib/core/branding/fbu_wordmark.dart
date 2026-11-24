import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'fbu_emblem_geometry.dart';

/// "FBU" wordmark (the "B" in accent) with an accent underline.
///
/// Sized proportionally to the emblem it accompanies.
class FbuWordmark extends StatelessWidget {
  const FbuWordmark({
    super.key,
    this.emblemSize = FbuLogoMetrics.designEmblemSize,
  });

  final double emblemSize;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final k = FbuLogoMetrics.scaleFor(emblemSize);
    final fontSize = FbuLogoMetrics.wordmarkFontSize * k;
    final letterSpacing = fontSize * FbuLogoMetrics.wordmarkLetterSpacing;
    final style = TextStyle(
      fontFamily: tokens.brandFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: letterSpacing,
      height: 1,
      color: tokens.textPrimary,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          // Compensates the spacing after the last letter to stay centered.
          padding: EdgeInsets.only(left: letterSpacing),
          child: Text.rich(
            TextSpan(
              style: style,
              children: [
                const TextSpan(text: 'F'),
                TextSpan(
                  text: 'B',
                  style: TextStyle(color: tokens.accent),
                ),
                const TextSpan(text: 'U'),
              ],
            ),
            semanticsLabel: 'FBU',
            textScaler: TextScaler.noScaling,
          ),
        ),
        SizedBox(height: FbuLogoMetrics.wordmarkUnderlineGap * k),
        Container(
          width: FbuLogoMetrics.wordmarkUnderlineWidth * k,
          height: FbuLogoMetrics.wordmarkUnderlineHeight * k,
          decoration: BoxDecoration(
            color: tokens.accent,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
          ),
        ),
      ],
    );
  }
}
