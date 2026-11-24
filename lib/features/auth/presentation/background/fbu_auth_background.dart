import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import 'auth_background_painter.dart';
import 'auth_background_spec.dart';

/// Animated background shared by every auth screen: four drifting green
/// glows that breathe, faded out below 45 % of the screen, plus film grain.
///
/// A single [Ticker] drives every layer from one clock, so changing
/// [variant] only animates the group transform (600 ms) while the waves keep
/// their course. The ticker stops with reduced motion, while the app is in
/// the background and while an opaque route covers it ([TickerMode]).
class FbuAuthBackground extends StatefulWidget {
  const FbuAuthBackground({super.key, required this.variant});

  final AuthBackgroundVariant variant;

  @override
  State<FbuAuthBackground> createState() => _FbuAuthBackgroundState();
}

class _FbuAuthBackgroundState extends State<FbuAuthBackground>
    with TickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  late final AnimationController _variant = AnimationController(
    vsync: this,
    value: _targetOf(widget.variant),
  );
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onHide: _pause,
    onShow: _resumeIfAllowed,
  );

  /// Animation time in seconds (real time × [AuthBackgroundSpec.speed]),
  /// excluding paused time.
  final ValueNotifier<double> _seconds = ValueNotifier(0);

  /// Time accumulated by previous runs of [_ticker] (it restarts at zero).
  Duration _accumulated = Duration.zero;
  Duration _lastElapsed = Duration.zero;
  bool _reduceMotion = false;

  static double _targetOf(AuthBackgroundVariant variant) =>
      variant == AuthBackgroundVariant.form ? 1 : 0;

  @override
  void initState() {
    super.initState();
    _lifecycle; // Starts listening.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      // Layers rest on their 0 % keyframe.
      _pause();
      _accumulated = Duration.zero;
      _seconds.value = 0;
    } else {
      _resumeIfAllowed();
    }
  }

  @override
  void didUpdateWidget(FbuAuthBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) {
      _variant.animateTo(
        _targetOf(widget.variant),
        duration: _reduceMotion
            ? AuthBackgroundSpec.variantDurationReducedMotion
            : AuthBackgroundSpec.variantDuration,
        curve: AuthBackgroundSpec.variantCurve,
      );
    }
  }

  void _onTick(Duration elapsed) {
    _lastElapsed = elapsed;
    _seconds.value =
        (_accumulated + elapsed).inMicroseconds /
        Duration.microsecondsPerSecond *
        AuthBackgroundSpec.speed;
  }

  void _resumeIfAllowed() {
    if (_reduceMotion || _ticker.isActive) return;
    _ticker.start();
  }

  void _pause() {
    if (!_ticker.isActive) return;
    _accumulated += _lastElapsed;
    _lastElapsed = Duration.zero;
    _ticker.stop();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _ticker.dispose();
    _variant.dispose();
    _seconds.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: tokens.background),
            RepaintBoundary(
              child: CustomPaint(
                painter: AuthBackgroundPainter(
                  time: _seconds,
                  variant: _variant,
                  tokens: tokens,
                  breathing: !_reduceMotion,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AuthBackgroundSpec.grainAsset),
                  repeat: ImageRepeat.repeat,
                  alignment: Alignment.topLeft,
                  opacity: AuthBackgroundSpec.grainOpacity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
