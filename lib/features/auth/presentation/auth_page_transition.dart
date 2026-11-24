import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'auth_metrics.dart';

/// Page of a screen inside the auth shell. Only the content animates (the
/// background lives outside the routes):
///
/// - The leaving screen fades out in 150 ms.
/// - The arriving screen waits 200 ms, then fades in while rising 12 → 0 dp
///   (400 ms, `easeOutCubic`).
///
/// Works the same for push and pop. Instant with
/// `MediaQuery.disableAnimations`.
CustomTransitionPage<void> authPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : AuthMetrics.pageEntryDelay + AuthMetrics.pageEntry;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        AuthPageTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
  );
}

/// See [authPage].
class AuthPageTransition extends StatelessWidget {
  const AuthPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  /// This page's own route animation (forward: pushed; reverse: popped).
  final Animation<double> animation;

  /// The animation of the route above (forward: covered; reverse: revealed).
  final Animation<double> secondaryAnimation;
  final Widget child;

  static double get _total =>
      (AuthMetrics.pageEntryDelay + AuthMetrics.pageEntry).inMicroseconds
          .toDouble();

  static final Curve _entry = Interval(
    AuthMetrics.pageEntryDelay.inMicroseconds / _total,
    1,
    curve: AuthMetrics.pageEntryCurve,
  );

  static final double _exitFraction =
      AuthMetrics.pageExit.inMicroseconds / _total;

  /// Progress (0–1) of an entry that started [progress] ago.
  static double entry(double progress) => _entry.transform(progress);

  /// Opacity of an exit that started [progress] ago.
  static double exit(double progress) =>
      1 - (progress / _exitFraction).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, child) {
        var opacity = 1.0;
        var rise = 0.0;

        // This page arriving (push) or leaving (pop).
        if (animation.status == AnimationStatus.reverse) {
          opacity *= exit(1 - animation.value);
        } else {
          final shown = entry(animation.value);
          opacity *= shown;
          rise = 1 - shown;
        }

        // Another page covering this one (push) or revealing it (pop).
        if (secondaryAnimation.status == AnimationStatus.reverse) {
          final shown = entry(1 - secondaryAnimation.value);
          opacity *= shown;
          rise = 1 - shown;
        } else {
          opacity *= exit(secondaryAnimation.value);
        }

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, AuthMetrics.pageEntryOffset * rise),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
