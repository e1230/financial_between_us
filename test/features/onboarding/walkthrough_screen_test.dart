import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/features/onboarding/presentation/walkthrough_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _welcome = 'WELCOME';
const _title1 = 'Auditoría de gastos';
const _title2 = 'Transparencia monetaria';
const _title3 = 'Flexibilidad económica';

void main() {
  Future<void> pumpWalkthrough(
    WidgetTester tester, {
    Size size = const Size(360, 800),
    bool disableAnimations = false,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.walkthrough,
      routes: [
        GoRoute(
          path: AppRoutes.walkthrough,
          builder: (context, state) => const WalkthroughScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const Scaffold(body: Text(_welcome)),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.dark,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
      ),
    );
    await tester.pump();
  }

  /// Advances time frame by frame (Ken Burns repeats forever, so
  /// `pumpAndSettle` never settles).
  Future<void> advance(WidgetTester tester, Duration duration) async {
    const frame = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += frame) {
      await tester.pump(frame);
    }
  }

  Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await advance(tester, const Duration(milliseconds: 600));
  }

  double skipOpacity(WidgetTester tester) => tester
      .widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text('Saltar'),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;

  testWidgets('page 1 shows its content, "Saltar" and "Siguiente"', (
    tester,
  ) async {
    await pumpWalkthrough(tester);

    expect(find.text('Bienvenido a FBU'), findsOneWidget);
    expect(find.text(_title1), findsOneWidget);
    expect(find.text('Registra cada salida en segundos.'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
    expect(skipOpacity(tester), 1);
    expect(find.bySemanticsLabel('Página 1 de 3'), findsWidgets);
  });

  testWidgets('"Siguiente" advances and page 3 shows "Empezar" without '
      '"Saltar"', (tester) async {
    await pumpWalkthrough(tester);

    await tapAndWait(tester, find.text('Siguiente'));
    expect(find.text(_title2), findsOneWidget);
    expect(skipOpacity(tester), 1);

    await tapAndWait(tester, find.text('Siguiente'));
    expect(find.text(_title3), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
    expect(find.text('Siguiente'), findsNothing);
    expect(skipOpacity(tester), 0);
  });

  testWidgets('"Saltar" goes to welcome', (tester) async {
    await pumpWalkthrough(tester);

    await tapAndWait(tester, find.text('Saltar'));
    expect(find.text(_welcome), findsOneWidget);
  });

  testWidgets('"Empezar" goes to welcome', (tester) async {
    await pumpWalkthrough(tester);
    await tapAndWait(tester, find.text('Siguiente'));
    await tapAndWait(tester, find.text('Siguiente'));

    await tapAndWait(tester, find.text('Empezar'));
    expect(find.text(_welcome), findsOneWidget);
  });

  testWidgets('system back on page 2 returns to page 1', (tester) async {
    await pumpWalkthrough(tester);
    await tapAndWait(tester, find.text('Siguiente'));

    await tester.binding.handlePopRoute();
    await advance(tester, const Duration(milliseconds: 600));

    expect(find.text(_title1), findsOneWidget);
    expect(find.text(_title2), findsNothing);
  });

  testWidgets('auto-advances every 6 s and stops on page 3', (tester) async {
    await pumpWalkthrough(tester);

    await advance(tester, const Duration(milliseconds: 5800));
    expect(find.text(_title1), findsOneWidget);

    await advance(tester, const Duration(milliseconds: 700));
    expect(find.text(_title2), findsOneWidget);

    await advance(tester, const Duration(seconds: 20));
    expect(find.text(_title3), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
    expect(find.text(_welcome), findsNothing);
  });

  testWidgets('holding the screen pauses the auto-advance', (tester) async {
    await pumpWalkthrough(tester);

    final gesture = await tester.startGesture(const Offset(180, 400));
    await advance(tester, const Duration(seconds: 8));
    expect(find.text(_title1), findsOneWidget);

    await gesture.up();
    await advance(tester, const Duration(milliseconds: 6500));
    expect(find.text(_title2), findsOneWidget);
  });

  testWidgets('no auto-advance with animations disabled', (tester) async {
    await pumpWalkthrough(tester, disableAnimations: true);

    await advance(tester, const Duration(seconds: 10));
    expect(find.text(_title1), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await tester.pump();
    expect(find.text(_title2), findsOneWidget);
  });

  for (final size in const [Size(360, 640), Size(360, 800), Size(412, 915)]) {
    testWidgets('no overflow at 130 % text on ${size.width}×${size.height}', (
      tester,
    ) async {
      await pumpWalkthrough(tester, size: size, textScale: 1.3);
      for (var page = 0; page < 3; page++) {
        await advance(tester, const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
        if (page < 2) await tester.tap(find.text('Siguiente'));
      }
    });
  }
}
