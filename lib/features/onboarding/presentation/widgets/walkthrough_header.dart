import 'package:material_ui/material_ui.dart';

import '../../../../core/branding/fbu_mini_emblem.dart';
import '../../../../core/theme/app_tokens.dart';
import '../walkthrough_metrics.dart';
import '../walkthrough_pages.dart';
import '../walkthrough_text_styles.dart';

/// Emblem + "Bienvenido a FBU" on the left and "Saltar" on the right.
///
/// When [showSkip] is false, "Saltar" fades out but keeps its space.
class WalkthroughHeader extends StatelessWidget {
  const WalkthroughHeader({
    super.key,
    required this.showSkip,
    required this.onSkip,
  });

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = WalkthroughTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      height: WalkthroughMetrics.headerHeight,
      child: Row(
        children: [
          const FbuMiniEmblem(size: WalkthroughMetrics.emblemSize),
          SizedBox(width: tokens.space1),
          Expanded(
            child: Text(
              WalkthroughCopy.header,
              style: styles.headerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ExcludeSemantics(
            excluding: !showSkip,
            child: IgnorePointer(
              ignoring: !showSkip,
              child: AnimatedOpacity(
                opacity: showSkip ? 1 : 0,
                duration: reduceMotion ? Duration.zero : tokens.motionShort,
                child: TextButton(
                  onPressed: onSkip,
                  style:
                      TextButton.styleFrom(
                        foregroundColor: tokens.textPrimary,
                        textStyle: styles.headerLabel,
                        minimumSize: const Size(
                          0,
                          WalkthroughMetrics.headerHeight,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.space2,
                        ),
                        shape: const StadiumBorder(),
                      ).copyWith(
                        // Solid pill ripple, as in the design.
                        overlayColor: WidgetStatePropertyAll(
                          tokens.surfaceVariant,
                        ),
                      ),
                  child: const Text(WalkthroughCopy.skip),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
