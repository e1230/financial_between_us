import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../walkthrough_metrics.dart';
import '../walkthrough_pages.dart';

/// Page indicator: the active dot is a green pill, the rest gray dots.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : WalkthroughMetrics.dots;
    return Semantics(
      container: true,
      label: WalkthroughCopy.pageOf(current + 1, count),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(width: tokens.space1),
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeInOut,
                width: i == current
                    ? WalkthroughMetrics.dotActiveWidth
                    : WalkthroughMetrics.dotSize,
                height: WalkthroughMetrics.dotSize,
                decoration: BoxDecoration(
                  color: i == current ? tokens.accent : tokens.textDisabled,
                  borderRadius: BorderRadius.circular(
                    WalkthroughMetrics.dotRadius,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
