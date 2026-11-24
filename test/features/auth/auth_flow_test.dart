import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/features/auth/presentation/background/auth_background_spec.dart';
import 'package:financial_between_us/features/auth/presentation/background/fbu_auth_background.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

const _home = 'HOME';

void main() {
  late GoRouter router;

  Future<void> pumpAuth(
    WidgetTester tester, {
    String location = AppRoutes.welcome,
    Size size = const Size(360, 800),
    bool disableAnimations = false,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    router = GoRouter(
      initialLocation: location,
      routes: [
        authShellRoute(),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const Scaffold(body: Text(_home)),
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

  /// Advances time frame by frame (the background animates forever, so
  /// `pumpAndSettle` never settles).
  Future<void> advance(WidgetTester tester, Duration duration) async {
    const frame = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += frame) {
      await tester.pump(frame);
    }
  }

  Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await advance(tester, const Duration(milliseconds: 800));
  }

  Finder field(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(Column)).first;

  Future<void> enter(WidgetTester tester, String label, String text) async {
    await tester.enterText(
      find.descendant(of: field(label), matching: find.byType(TextField)),
      text,
    );
    // Lets the helper/error cross-fade (200 ms) finish.
    await advance(tester, const Duration(milliseconds: 300));
  }

  AuthBackgroundVariant variant(WidgetTester tester) =>
      tester.widget<FbuAuthBackground>(find.byType(FbuAuthBackground)).variant;

  testWidgets('welcome shows its title, actions and the v1 background', (
    tester,
  ) async {
    await pumpAuth(tester);
    await advance(tester, const Duration(milliseconds: 800));

    expect(find.text('Ingresa al aplicativo'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byTooltip('Volver'), findsNothing);
    expect(variant(tester), AuthBackgroundVariant.welcome);
  });

  testWidgets('moving to sign-up switches to v2 without rebuilding the '
      'background', (tester) async {
    await pumpAuth(tester);
    final before = tester.state(find.byType(FbuAuthBackground));

    await tapAndWait(tester, find.text('Crear cuenta'));

    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(variant(tester), AuthBackgroundVariant.form);
    expect(tester.state(find.byType(FbuAuthBackground)), same(before));

    await tester.tap(find.byTooltip('Volver'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text('Ingresa al aplicativo'), findsOneWidget);
    expect(variant(tester), AuthBackgroundVariant.welcome);
  });

  testWidgets('sign-up validates on submit and lowercases the username', (
    tester,
  ) async {
    await pumpAuth(tester, location: AppRoutes.register);
    await advance(tester, const Duration(milliseconds: 800));

    // Nothing is validated while typing before the first submit.
    expect(find.text('Escribe tu correo.'), findsNothing);

    await tapAndWait(tester, find.text('Crear cuenta'));
    expect(find.text('Escribe un nombre de usuario.'), findsOneWidget);
    expect(find.text('Escribe tu correo.'), findsOneWidget);
    expect(find.text('Le faltan 8 caracteres: mínimo 8.'), findsOneWidget);

    // After the first submit each field revalidates on change.
    await enter(tester, 'Nombre de usuario', 'JuanEs_92');
    expect(find.text('juanes_92'), findsOneWidget);
    expect(find.text('Escribe un nombre de usuario.'), findsNothing);

    await enter(tester, 'Correo electrónico', 'juan@');
    expect(find.text('Escribe un correo válido.'), findsOneWidget);
  });

  testWidgets('register footer replaces itself with login', (tester) async {
    await pumpAuth(tester);
    await tapAndWait(tester, find.text('Crear cuenta'));
    await tapAndWait(tester, find.text('Inicia sesión'));
    expect(find.text('Hola de nuevo'), findsOneWidget);

    // Back skips the replaced sign-up screen.
    await tester.tap(find.byTooltip('Volver'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text('Ingresa al aplicativo'), findsOneWidget);
  });

  testWidgets('login shows the loading state and then goes home', (
    tester,
  ) async {
    await pumpAuth(tester, location: AppRoutes.login);
    await advance(tester, const Duration(milliseconds: 800));

    await enter(tester, 'Usuario o correo', 'juanes_92');
    await enter(tester, 'Contraseña', 'cuentasclaras');
    await tester.tap(find.text('Iniciar sesión'));
    await advance(tester, const Duration(milliseconds: 300));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final back = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.arrow_back),
        matching: find.byType(IconButton),
      ),
    );
    expect(back.onPressed, isNull);
    expect(tester.widget<PopScope>(find.byType(PopScope).last).canPop, isFalse);

    await advance(tester, const Duration(seconds: 2));
    expect(find.text(_home), findsOneWidget);
  });

  testWidgets('recover → sent masks the email and unlocks resend after 45 s', (
    tester,
  ) async {
    await pumpAuth(tester, location: AppRoutes.login);
    await tapAndWait(tester, find.text('¿Olvidaste tu contraseña?'));
    expect(find.text('Recupera tu contraseña'), findsOneWidget);

    await enter(tester, 'Correo electrónico', 'juan@correo.com');
    await enter(tester, 'Nueva contraseña', 'cuentas2026');
    await tester.tap(find.text('Enviar'));
    await advance(tester, const Duration(milliseconds: 2400));

    expect(find.text('Revisa tu correo'), findsOneWidget);
    expect(find.textContaining('j•••@correo.com'), findsOneWidget);
    expect(find.text('Reenviar en 0:45'), findsOneWidget);

    await advance(tester, const Duration(seconds: 45));
    expect(find.text('Reenviar correo'), findsOneWidget);

    // Back goes to recover, then to login.
    await tester.tap(find.byTooltip('Volver'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text('Recupera tu contraseña'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text('Hola de nuevo'), findsOneWidget);
  });

  testWidgets('the background stops with reduced motion', (tester) async {
    await pumpAuth(tester, disableAnimations: true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('the background keeps animating normally', (tester) async {
    await pumpAuth(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  for (final location in [
    AppRoutes.welcome,
    AppRoutes.register,
    AppRoutes.login,
    AppRoutes.recover,
    AppRoutes.recoverSent,
    AppRoutes.chooseUsername,
  ]) {
    testWidgets('no overflow at 130 % text on 360×640: $location', (
      tester,
    ) async {
      await pumpAuth(
        tester,
        location: location,
        size: const Size(360, 640),
        textScale: 1.3,
      );
      await advance(tester, const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);
    });
  }
}
