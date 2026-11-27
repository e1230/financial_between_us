import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import 'balances_metrics.dart';
import 'balances_strings.dart';
import 'balances_text_styles.dart';

/// Hero tag of the image of the movement [movementId].
String attachmentTag(String movementId) => 'adjunto-$movementId';

/// What the image viewer shows.
final class AttachmentViewerArgs {
  /// An uploaded image.
  const AttachmentViewerArgs.network({
    required String this.url,
    required this.heroTag,
  }) : filePath = null;

  /// An image still on the device (before saving the movement).
  const AttachmentViewerArgs.file({
    required String this.filePath,
    required this.heroTag,
  }) : url = null;

  final String? url;
  final String? filePath;
  final String heroTag;
}

/// The image of a movement, full screen on black, with pinch zoom (1 to 4×)
/// and a close button at the top left. Flies in as a Hero from its
/// thumbnail (not with `MediaQuery.disableAnimations`).
class AttachmentViewerScreen extends StatelessWidget {
  const AttachmentViewerScreen({super.key, required this.args});

  /// `null` when the route was opened without arguments.
  final AttachmentViewerArgs? args;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final args = this.args;
    final error = Center(
      child: Text(BalancesStrings.imageUnavailable, style: styles.body),
    );
    return Scaffold(
      backgroundColor: tokens.brandBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: args == null
                ? error
                : InteractiveViewer(
                    maxScale: BalancesMetrics.viewerMaxScale,
                    child: Center(
                      child: HeroMode(
                        enabled: !MediaQuery.disableAnimationsOf(context),
                        child: Hero(
                          tag: args.heroTag,
                          child: Semantics(
                            image: true,
                            label: BalancesStrings.attachmentLabel,
                            child: Image(
                              image: args.url != null
                                  ? NetworkImage(args.url!)
                                  : FileImage(File(args.filePath!))
                                        as ImageProvider,
                              fit: BoxFit.contain,
                              errorBuilder: (context, _, _) => error,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: padding.top + BalancesMetrics.headerTopGap,
            left: BalancesMetrics.backLeft,
            child: IconButton(
              tooltip: BalancesStrings.closeViewer,
              iconSize: BalancesMetrics.chevronSize,
              constraints: const BoxConstraints.tightFor(
                width: BalancesMetrics.touchTarget,
                height: BalancesMetrics.touchTarget,
              ),
              color: tokens.textPrimary,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
