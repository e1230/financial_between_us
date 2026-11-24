import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/features/splash/presentation/fbu_splash_animation.dart';
import 'package:financial_between_us/features/splash/presentation/splash_timeline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Duration _seconds(double s) => Duration(milliseconds: (s * 1000).round());

void main() {
  late int finishedCount;

  setUp(() => finishedCount = 0);

  Widget app({required bool ready, bool disableAnimations = false}) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: FbuSplashAnimation(
          ready: ready,
          onFinished: () => finishedCount++,
        ),
      ),
    );
  }

  /// Advances the ticker frame by frame for [seconds].
  Future<void> advance(WidgetTester tester, double seconds) async {
    const frame = Duration(milliseconds: 100);
    final frames = (seconds * 10).ceil();
    for (var i = 0; i < frames; i++) {
      await tester.pump(frame);
    }
  }

  testWidgets('finishes once after the full timeline when ready', (
    tester,
  ) async {
    await tester.pumpWidget(app(ready: true));

    await advance(tester, SplashTimeline.minTotal - 0.3);
    expect(finishedCount, 0);

    await advance(tester, 0.6);
    expect(finishedCount, 1);

    await advance(tester, 2);
    expect(finishedCount, 1);
  });

  testWidgets('keeps looping while startup is not ready', (tester) async {
    await tester.pumpWidget(app(ready: false));

    await advance(tester, 10);
    expect(finishedCount, 0);

    await tester.pumpWidget(app(ready: true));
    await advance(
      tester,
      SplashTimeline.fadeDelay + SplashTimeline.fadeOut + 0.3,
    );
    expect(finishedCount, 1);
  });

  testWidgets('shows the static logo when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(app(ready: true, disableAnimations: true));

    expect(find.bySemanticsLabel('FBU'), findsOneWidget);

    await tester.pump(_seconds(SplashTimeline.reducedMotionHold + 0.1));
    await tester.pump(_seconds(0.1));
    expect(finishedCount, 1);
  });
}
