import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';
import '../home_strings.dart';

/// Three placeholder rows while the movements load.
class MovementSkeleton extends StatelessWidget {
  const MovementSkeleton({super.key});

  /// Widths of the two text bars, relative to the free width.
  static const double titleWidth = 0.6;
  static const double detailWidth = 0.4;
  static const double amountWidth = 64;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget bar(double width) => Container(
      width: width,
      height: HomeMetrics.skeletonLine,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
    );
    return Semantics(
      label: HomeStrings.loadingMovements,
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var i = 0; i < HomeMetrics.skeletonRows; i++)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: HomeMetrics.movementPaddingVertical,
                ),
                child: Row(
                  children: [
                    Container(
                      width: HomeMetrics.movementIconCircle,
                      height: HomeMetrics.movementIconCircle,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: HomeMetrics.movementGap),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bar(constraints.maxWidth * titleWidth),
                            SizedBox(height: tokens.space1),
                            bar(constraints.maxWidth * detailWidth),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: HomeMetrics.movementGap),
                    bar(amountWidth),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
