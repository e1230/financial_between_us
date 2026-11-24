import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../walkthrough_metrics.dart';
import '../walkthrough_pages.dart';

/// Story-like progress bar: one segment per page. Segments before [current]
/// are full, after it empty, and the current one follows [progress].
class ProgressSegments extends StatelessWidget {
  const ProgressSegments({
    super.key,
    required this.count,
    required this.current,
    required this.progress,
  });

  final int count;
  final int current;

  /// Fill of the current segment, from 0 to 1.
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = BorderRadius.circular(WalkthroughMetrics.progressRadius);
    return Semantics(
      container: true,
      label: WalkthroughCopy.pageOf(current + 1, count),
      child: ExcludeSemantics(
        child: SizedBox(
          height: WalkthroughMetrics.progressHeight,
          child: Row(
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0)
                  const SizedBox(width: WalkthroughMetrics.progressGap),
                Expanded(
                  child: ClipRRect(
                    borderRadius: radius,
                    child: ColoredBox(
                      color: tokens.progressTrack,
                      child: AnimatedBuilder(
                        animation: progress,
                        builder: (context, _) => FractionallySizedBox(
                          alignment: AlignmentDirectional.centerStart,
                          widthFactor: i < current
                              ? 1
                              : i > current
                              ? 0
                              : progress.value,
                          child: ColoredBox(color: tokens.accent),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
