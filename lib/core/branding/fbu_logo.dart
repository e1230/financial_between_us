import 'package:material_ui/material_ui.dart';

import 'fbu_emblem.dart';
import 'fbu_emblem_geometry.dart';
import 'fbu_wordmark.dart';

/// Static Financial Between Us logo: the emblem and, optionally, the "FBU"
/// wordmark below it (same layout as the last frame of the splash).
class FbuLogo extends StatelessWidget {
  const FbuLogo({
    super.key,
    this.size = FbuLogoMetrics.designEmblemSize,
    this.showWordmark = true,
  });

  /// Emblem size in logical pixels; the wordmark scales with it.
  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    if (!showWordmark) return FbuEmblem(size: size);

    final k = FbuLogoMetrics.scaleFor(size);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FbuEmblem(size: size),
        SizedBox(height: FbuLogoMetrics.emblemToWordmarkGap * k),
        FbuWordmark(emblemSize: size),
      ],
    );
  }
}
