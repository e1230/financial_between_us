import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/fbu_primary_button.dart';
import 'walkthrough_metrics.dart';
import 'walkthrough_pages.dart';
import 'widgets/page_dots.dart';
import 'widgets/progress_segments.dart';
import 'widgets/walkthrough_header.dart';
import 'widgets/walkthrough_page.dart';

/// Why the auto-advance is paused. It runs only when the set is empty.
enum _Pause { hold, drag, background }

/// First-launch walkthrough: three full-bleed pages that advance on their own
/// every 6 s (story-like progress bar), with "Saltar"/"Empezar" leading to the
/// welcome screen.
///
/// Without animations (`disableAnimations`) or with a screen reader
/// (`accessibleNavigation`) there is no auto-advance nor Ken Burns, and every
/// transition is instant.
class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen>
    with TickerProviderStateMixin {
  static final int _lastPage = walkthroughPages.length - 1;

  final _pageController = PageController();
  late final AnimationController _progress;
  late final AnimationController _kenBurns;
  late final AnimationController _entry;
  late final AppLifecycleListener _lifecycle;

  final Set<_Pause> _pauses = {};
  final Set<int> _pointers = {};

  /// Page shown by the dots, button and progress bar (changes mid-swipe).
  int _current = 0;

  /// Page the user is resting on; its text and photo are animated.
  int _settled = 0;

  bool _reduceMotion = false;
  bool _autoAdvance = true;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: WalkthroughMetrics.autoAdvance,
    )..addStatusListener(_onProgressStatus);
    _kenBurns = AnimationController(
      vsync: this,
      duration: WalkthroughMetrics.kenBurns,
    );
    _entry = AnimationController(
      vsync: this,
      duration:
          WalkthroughMetrics.textEntry + WalkthroughMetrics.subtitleEntryDelay,
    );
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) => _setPaused(
        _Pause.background,
        paused: state != AppLifecycleState.resumed,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _autoAdvance =
        !_reduceMotion && !MediaQuery.accessibleNavigationOf(context);

    for (final page in walkthroughPages.skip(1)) {
      precacheImage(page.imageProvider(context), context);
    }

    if (!_started) {
      _started = true;
      _onSettled(0);
    } else {
      _syncMotion();
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _pageController.dispose();
    _progress.dispose();
    _kenBurns.dispose();
    _entry.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auto-advance

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _current < _lastPage) {
      _goToPage(_current + 1);
    }
  }

  void _setPaused(_Pause reason, {required bool paused}) {
    final changed = paused ? _pauses.add(reason) : _pauses.remove(reason);
    if (changed) _syncProgress();
  }

  /// Runs the progress of the current page unless paused or disabled.
  void _syncProgress() {
    if (_autoAdvance && _pauses.isEmpty) {
      if (!_progress.isAnimating && !_progress.isCompleted) _progress.forward();
    } else {
      _progress.stop();
    }
  }

  /// Applies the current motion settings to every controller.
  void _syncMotion() {
    if (!_autoAdvance) _progress.stop();
    if (_reduceMotion) {
      _kenBurns
        ..stop()
        ..value = 0;
      _entry.value = 1;
    }
    _syncProgress();
  }

  // ---------------------------------------------------------------------------
  // Pages

  void _onPageChanged(int page) {
    setState(() => _current = page);
    _progress.value = 0;
    _syncProgress();
    // Without animations there is no swipe to wait for.
    if (_reduceMotion) _onSettled(page);
  }

  /// Called when a page comes to rest: restarts its text entry and photo zoom.
  void _onSettled(int page) {
    if (page != _settled) setState(() => _settled = page);
    if (_reduceMotion) {
      _entry.value = 1;
      _kenBurns
        ..stop()
        ..value = 0;
    } else {
      _entry.forward(from: 0);
      _kenBurns
        ..value = 0
        ..repeat(reverse: true);
    }
    _syncProgress();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _setPaused(_Pause.drag, paused: true);
    } else if (notification is ScrollEndNotification) {
      _setPaused(_Pause.drag, paused: false);
      final page = _pageController.page?.round() ?? _current;
      if (page != _settled) _onSettled(page);
    }
    return false;
  }

  void _goToPage(int page) {
    if (_reduceMotion) {
      _pageController.jumpToPage(page);
    } else {
      _pageController.animateToPage(
        page,
        duration: WalkthroughMetrics.pageTransition,
        curve: WalkthroughMetrics.pageTransitionCurve,
      );
    }
  }

  void _onPrimaryPressed() {
    if (_current < _lastPage) {
      _goToPage(_current + 1);
    } else {
      _exit();
    }
  }

  void _exit() => context.go(AppRoutes.welcome);

  // ---------------------------------------------------------------------------
  // Hold to pause

  void _onPointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
    _setPaused(_Pause.hold, paused: true);
  }

  void _onPointerUp(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty) _setPaused(_Pause.hold, paused: false);
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final padding = MediaQuery.paddingOf(context);
    final layout = WalkthroughLayout.of(context);
    final isLast = _current == _lastPage;

    // Bottom stack: button (56) + 24 + dots (8) + gap to the text.
    final controlsTop =
        padding.bottom +
        tokens.space2 +
        FbuPrimaryButton.height +
        tokens.space3 +
        WalkthroughMetrics.dotSize;
    final progressTop = padding.top + tokens.space1;
    final headerTop =
        progressTop + WalkthroughMetrics.progressHeight + tokens.space1;

    return PopScope(
      canPop: _current == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _current > 0) _goToPage(_current - 1);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: Listener(
                onPointerDown: _onPointerDown,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerUp,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  itemCount: walkthroughPages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final settled = index == _settled;
                    return WalkthroughPage(
                      data: walkthroughPages[index],
                      index: index,
                      pageController: _pageController,
                      kenBurns: settled ? _kenBurns : kAlwaysDismissedAnimation,
                      // DECISIÓN: pages other than the settled one keep their
                      // text hidden (or fully shown without animations) so the
                      // incoming text animates in only once the swipe ends.
                      entry: settled
                          ? _entry
                          : _reduceMotion
                          ? kAlwaysCompleteAnimation
                          : kAlwaysDismissedAnimation,
                      bottomInset: controlsTop + layout.textToDotsGap,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: progressTop,
              left: tokens.space2,
              right: tokens.space2,
              child: ProgressSegments(
                count: walkthroughPages.length,
                current: _current,
                progress: _autoAdvance
                    ? _progress
                    : const AlwaysStoppedAnimation(1),
              ),
            ),
            Positioned(
              top: headerTop,
              left: tokens.space2,
              right: tokens.space1,
              child: WalkthroughHeader(showSkip: !isLast, onSkip: _exit),
            ),
            Positioned(
              left: tokens.space3,
              right: tokens.space3,
              bottom: padding.bottom + tokens.space2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageDots(count: walkthroughPages.length, current: _current),
                  SizedBox(height: tokens.space3),
                  FbuPrimaryButton(
                    onPressed: _onPrimaryPressed,
                    child: _ButtonLabel(
                      isLast ? WalkthroughCopy.start : WalkthroughCopy.next,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cross-fades "Siguiente" ↔ "Empezar" rising 8 dp.
class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: reduceMotion ? Duration.zero : context.tokens.motionShort,
      transitionBuilder: (child, animation) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              WalkthroughMetrics.buttonLabelRise * (1 - animation.value),
            ),
            child: child,
          ),
        ),
        child: child,
      ),
      child: Text(label, key: ValueKey(label)),
    );
  }
}
