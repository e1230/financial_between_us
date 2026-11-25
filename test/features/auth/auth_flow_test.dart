import 'dart:async';

import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/auth/domain/auth_failure.dart';
import 'package:financial_between_us/features/auth/domain/session_destination.dart';
import 'package:financial_between_us/features/auth/presentation/background/auth_background_spec.dart';
import 'package:financial_between_us/features/auth/presentation/background/fbu_auth_background.dart';
import 'package:financial_between_us/features/auth/presentation/widgets/auth_banner.dart';
import 'package:financial_between_us/features/auth/presentation/widgets/fbu_text_field.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

const _home = 'HOME';
const _profile = 'Completa tu perfil';
const _newUser = UserProfile(
  uid: 'uid-1',
  displayName: 'mao',
  nickname: 'mao',
  email: 'mao@correo.com',
);
const _chooseNickname = 'Elige tu nombre de usuario';

void main() {
  late GoRouter router;
  late FakeAuthRepository auth;

  setUp(() => auth = FakeAuthRepository());

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
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(_newUser),
          ),
        ],
        child: MaterialApp.router(
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
    auth.gate = Completer<void>();
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

    auth.gate!.complete();
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text(_home), findsOneWidget);
    expect(auth.calls, ['signIn:juanes_92']);
  });

  testWidgets('wrong credentials show the banner and red fields', (
    tester,
  ) async {
    auth.failure = const InvalidCredentials();
    await pumpAuth(tester, location: AppRoutes.login);
    await advance(tester, const Duration(milliseconds: 800));

    await enter(tester, 'Usuario o correo', 'juanes_92');
    await enter(tester, 'Contraseña', 'otra-clave');
    await tapAndWait(tester, find.text('Iniciar sesión'));

    expect(
      find.text(
        'El usuario o la contraseña no coinciden. Revisa e intenta de nuevo.',
      ),
      findsOneWidget,
    );
    final fields = tester.widgetList<FbuTextField>(find.byType(FbuTextField));
    expect(fields.every((f) => f.hasError), isTrue);

    // Editing a field clears the red borders.
    await enter(tester, 'Contraseña', 'otra-clave-2');
    final edited = tester.widgetList<FbuTextField>(find.byType(FbuTextField));
    expect(edited.any((f) => f.hasError), isFalse);
  });

  testWidgets('sign-up goes to complete the profile', (tester) async {
    await pumpAuth(tester, location: AppRoutes.register);
    await advance(tester, const Duration(milliseconds: 800));

    await enter(tester, 'Nombre de usuario', 'mao');
    await enter(tester, 'Correo electrónico', 'mao@correo.com');
    await enter(tester, 'Contraseña', 'cuentasclaras');
    await tapAndWait(tester, find.text('Crear cuenta'));

    expect(auth.calls, ['register:mao:mao@correo.com']);
    expect(find.text(_profile), findsOneWidget);
  });

  testWidgets('a taken nickname is shown below the username', (tester) async {
    auth.failure = const NicknameTaken();
    await pumpAuth(tester, location: AppRoutes.register);
    await advance(tester, const Duration(milliseconds: 800));

    await enter(tester, 'Nombre de usuario', 'mao');
    await enter(tester, 'Correo electrónico', 'mao@correo.com');
    await enter(tester, 'Contraseña', 'cuentasclaras');
    await tapAndWait(tester, find.text('Crear cuenta'));

    final username = tester.widget<FbuTextField>(
      find.byType(FbuTextField).first,
    );
    expect(username.errorText, 'Ese nombre ya está en uso. Prueba con otro.');
    expect(find.text('Crea tu cuenta'), findsOneWidget);
  });

  testWidgets('Google the first time asks for a nickname', (tester) async {
    auth.googleResult = SessionDestination.chooseNickname;
    await pumpAuth(tester, location: AppRoutes.login);
    await advance(tester, const Duration(milliseconds: 800));

    await tapAndWait(tester, find.text('Continuar con Google'));
    expect(find.text(_chooseNickname), findsOneWidget);

    await enter(tester, 'Nombre de usuario', 'ana');
    await tapAndWait(tester, find.text('Continuar'));
    expect(auth.calls, ['google', 'claim:ana']);
    expect(find.text(_profile), findsOneWidget);
  });

  testWidgets('closing the Google dialog shows nothing', (tester) async {
    auth.googleResult = null;
    await pumpAuth(tester, location: AppRoutes.register);
    await advance(tester, const Duration(milliseconds: 800));

    await tapAndWait(tester, find.text('Continuar con Google'));
    expect(find.text('Crea tu cuenta'), findsOneWidget);
    expect(find.byType(AuthBanner), findsNothing);
  });

  testWidgets('back from choosing a nickname signs out', (tester) async {
    await pumpAuth(tester, location: AppRoutes.chooseUsername);
    await advance(tester, const Duration(milliseconds: 800));

    await tester.tap(find.byTooltip('Volver'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text('Ingresa al aplicativo'), findsOneWidget);
    expect(auth.calls, ['signOut']);
  });

  testWidgets('recover → sent masks the email and unlocks resend after 45 s', (
    tester,
  ) async {
    await pumpAuth(tester, location: AppRoutes.login);
    await tapAndWait(tester, find.text('¿Olvidaste tu contraseña?'));
    expect(find.text('Recupera tu contraseña'), findsOneWidget);

    expect(find.text('Nueva contraseña'), findsNothing);
    await enter(tester, 'Correo electrónico', 'juan@correo.com');
    await tester.tap(find.text('Enviar'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(auth.calls, ['reset:juan@correo.com']);

    expect(find.text('Revisa tu correo'), findsOneWidget);
    expect(find.textContaining('j•••@correo.com'), findsOneWidget);
    expect(find.text('Reenviar en 0:45'), findsOneWidget);

    await advance(tester, const Duration(seconds: 45));
    expect(find.text('Reenviar correo'), findsOneWidget);
    await tapAndWait(tester, find.text('Reenviar correo'));
    expect(auth.calls, ['reset:juan@correo.com', 'reset:juan@correo.com']);
    expect(find.text('Reenviar en 0:45'), findsOneWidget);

    // Back goes to recover, then to login.
    await tester.tap(find.byTooltip('Volver'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text('Recupera tu contraseña'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await advance(tester, const Duration(milliseconds: 800));
    expect(find.text('Hola de nuevo'), findsOneWidget);
  });

  testWidgets('a network error keeps the user in recover', (tester) async {
    auth.failure = const NetworkFailure();
    await pumpAuth(tester, location: AppRoutes.recover);
    await advance(tester, const Duration(milliseconds: 800));

    await enter(tester, 'Correo electrónico', 'juan@correo.com');
    await tapAndWait(tester, find.text('Enviar'));
    expect(
      find.text('Sin conexión. Revisa tu internet e intenta de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Recupera tu contraseña'), findsOneWidget);
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
    AppRoutes.completeProfile,
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
