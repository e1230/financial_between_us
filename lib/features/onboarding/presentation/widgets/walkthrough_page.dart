import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../walkthrough_metrics.dart';
import '../walkthrough_pages.dart';
import '../walkthrough_text_styles.dart';

/// One page of the walkthrough: photo (Ken Burns + parallax), scrims and the
/// title/subtitle block. The dots and the button are drawn by the screen on
/// top, so [bottomInset] reserves their space.
class WalkthroughPage extends StatelessWidget {
  const WalkthroughPage({
    super.key,
    required this.data,
    required this.index,
    required this.pageController,
    required this.kenBurns,
    required this.entry,
    required this.bottomInset,
  });

  final WalkthroughPageData data;
  final int index;
  final PageController pageController;

  /// 0 → 1 zoom of the photo; [kAlwaysDismissedAnimation] when still.
  final Animation<double> kenBurns;

  /// 0 → 1 entry of the text; [kAlwaysCompleteAnimation] when shown.
  final Animation<double> entry;

  /// Distance from the bottom of the screen to the bottom of the text block.
  final double bottomInset;

  /// Signed page offset of this page while swiping (0 when settled).
  double _pageDelta() {
    final position = pageController.hasClients ? pageController.position : null;
    if (position == null || !position.hasContentDimensions) return 0;
    return (pageController.page ?? index.toDouble()) - index;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final layout = WalkthroughLayout.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Color scrim(double alpha) => tokens.background.withValues(alpha: alpha);

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: AnimatedBuilder(
            animation: Listenable.merge([pageController, kenBurns]),
            builder: (context, child) {
              final size = MediaQuery.sizeOf(context);
              final parallax = reduceMotion
                  ? 0.0
                  : _pageDelta() *
                        size.width *
                        WalkthroughMetrics.parallaxFactor;
              final t = Curves.easeInOut.transform(kenBurns.value);
              return Transform.translate(
                offset: Offset(
                  parallax - WalkthroughMetrics.kenBurnsShiftX * size.width * t,
                  -WalkthroughMetrics.kenBurnsShiftY * size.height * t,
                ),
                child: Transform.scale(
                  scale: 1 + WalkthroughMetrics.kenBurnsScale * t,
                  child: child,
                ),
              );
            },
            child: Image(
              image: data.imageProvider(context),
              fit: BoxFit.cover,
              alignment: data.imageAlignment,
              semanticLabel: data.imageSemanticLabel,
              gaplessPlayback: true,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: layout.topScrimHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  for (final a in WalkthroughMetrics.topScrimAlphas) scrim(a),
                ],
                stops: WalkthroughMetrics.topScrimStops,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  for (final a in WalkthroughMetrics.bottomScrimAlphas)
                    scrim(a),
                ],
                stops: WalkthroughMetrics.bottomScrimStops,
              ),
            ),
          ),
        ),
        Positioned(
          left: tokens.space3,
          right: tokens.space3,
          bottom: bottomInset,
          child: AnimatedBuilder(
            animation: pageController,
            builder: (context, child) => Opacity(
              opacity:
                  1 -
                  (_pageDelta().abs() * WalkthroughMetrics.textExitFadeFactor)
                      .clamp(0.0, 1.0),
              child: child,
            ),
            child: _TextBlock(data: data, entry: entry, layout: layout),
          ),
        ),
      ],
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.data,
    required this.entry,
    required this.layout,
  });

  final WalkthroughPageData data;
  final Animation<double> entry;
  final WalkthroughLayout layout;

  static const _total = 1.0;

  /// Title: 0 – 400 ms; subtitle: 80 – 480 ms (of a 480 ms controller).
  static double get _titleEnd =>
      WalkthroughMetrics.textEntry.inMicroseconds /
      (WalkthroughMetrics.textEntry + WalkthroughMetrics.subtitleEntryDelay)
          .inMicroseconds;
  static double get _subtitleStart => _total - _titleEnd;

  @override
  Widget build(BuildContext context) {
    final styles = WalkthroughTextStyles.of(context);
    final largeText =
        MediaQuery.textScalerOf(context).scale(1) >
        WalkthroughMetrics.largeTextScale;

    final title = CurvedAnimation(
      parent: entry,
      curve: Interval(0, _titleEnd, curve: Curves.easeOutCubic),
    );
    final subtitle = CurvedAnimation(
      parent: entry,
      curve: Interval(_subtitleStart, _total, curve: Curves.easeOutCubic),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: layout.textMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Entry(
            animation: title,
            child: Semantics(
              header: true,
              child: Text(
                data.title,
                style: styles.title,
                maxLines: largeText
                    ? WalkthroughMetrics.titleMaxLinesLargeText
                    : WalkthroughMetrics.titleMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(height: layout.titleToSubtitleGap),
          _Entry(
            animation: subtitle,
            child: Text(
              data.subtitle,
              style: styles.subtitle,
              maxLines: WalkthroughMetrics.subtitleMaxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades in and rises [WalkthroughMetrics.textEntryOffset] dp.
class _Entry extends StatelessWidget {
  const _Entry({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, WalkthroughMetrics.textEntryOffset * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
