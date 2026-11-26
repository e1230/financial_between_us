import 'dart:async';

import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/widgets/fbu_primary_button.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/auth/domain/auth_failure.dart';
import 'package:financial_between_us/features/auth/domain/sign_in_method.dart';
import 'package:financial_between_us/features/auth/presentation/widgets/fbu_text_field.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:financial_between_us/features/profile/presentation/profile_screen.dart';
import 'package:financial_between_us/features/profile/presentation/widgets/avatar_editor.dart';
import 'package:financial_between_us/features/profile/presentation/widgets/profile_form_skeleton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';

const _home = 'HOME';

void main() {
  late FakeUserProfileRepository profiles;
  late FakeAvatarUploader uploader;
  late FakeAvatarPicker picker;
  late FakeAuthRepository auth;

  const mao = UserProfile(
    uid: 'uid-1',
    displayName: 'Mauricio Beltrán',
    nickname: 'mao',
    email: 'mao@correo.com',
    profileCompleted: true,
  );

  setUp(() {
    profiles = FakeUserProfileRepository(profiles: {'uid-1': mao});
    uploader = FakeAvatarUploader();
    picker = FakeAvatarPicker();
    auth = FakeAuthRepository();
  });

  Future<void> advance(WidgetTester tester, Duration duration) async {
    const frame = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += frame) {
      await tester.pump(frame);
    }
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    SignInMethod? method = SignInMethod.password,
    Stream<UserProfile?>? liveProfile,
    double textScale = 1,
    Size size = const Size(360, 800),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
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
          userProfileRepositoryProvider.overrideWithValue(profiles),
          currentUserProfileProvider.overrideWith(
            (ref) => liveProfile ?? profiles.watch('uid-1'),
          ),
          currentSignInMethodProvider.overrideWith((ref) async => method),
          avatarUploaderProvider.overrideWithValue(uploader),
          avatarPickerProvider.overrideWithValue(picker),
          authRepositoryProvider.overrideWithValue(auth),
        ],
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await advance(tester, const Duration(milliseconds: 800));
  }

  Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await advance(tester, const Duration(milliseconds: 800));
  }

  Finder field(String label) =>
      find.ancestor(of: find.text(label), matching: find.byType(FbuTextField));

  Finder input(String label) =>
      find.descendant(of: field(label), matching: find.byType(TextField));

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<FbuPrimaryButton>(find.byType(FbuPrimaryButton))
          .onPressed !=
      null;

  group('content', () {
    testWidgets('shows the profile; nickname and email are read-only', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('Perfil'), findsOneWidget);
      // Avatar heading and the field (its value and its hint).
      expect(find.text('Mauricio Beltrán'), findsWidgets);
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('@mao'), findsNWidgets(2));
      expect(find.text('mao@correo.com'), findsOneWidget);
      // Only the name is a text field.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    });

    testWidgets('a Google account shows "Ingresado con Google"', (
      tester,
    ) async {
      await pumpScreen(tester, method: SignInMethod.google);
      expect(find.text('Ingresado con Google'), findsOneWidget);
      expect(find.text('Cambiar'), findsNothing);
    });

    testWidgets('an email account can change the password', (tester) async {
      await pumpScreen(tester);
      expect(find.text('••••••••'), findsOneWidget);
      expect(find.text('Cambiar'), findsOneWidget);
      expect(find.text('Ingresado con Google'), findsNothing);
    });

    testWidgets('shows a skeleton while loading', (tester) async {
      final live = StreamController<UserProfile?>();
      addTearDown(live.close);
      await pumpScreen(tester, liveProfile: live.stream);
      expect(find.byType(ProfileFormSkeleton), findsOneWidget);
    });

    testWidgets('a load error offers to retry', (tester) async {
      await pumpScreen(tester, liveProfile: Stream.error(Exception('x')));
      expect(find.text('No pudimos cargar tu perfil.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('no overflow at 130 % text on 360×640', (tester) async {
      await pumpScreen(tester, textScale: 1.3, size: const Size(360, 640));
      expect(tester.takeException(), isNull);
    });
  });

  group('save and cancel', () {
    testWidgets('Guardar is disabled until something changes', (tester) async {
      await pumpScreen(tester);
      expect(saveEnabled(tester), isFalse);

      await tapAndWait(tester, find.byTooltip('Celeste'));
      expect(saveEnabled(tester), isTrue);
    });

    testWidgets('saves name, color and photo and stays here', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(input('Nombres'), 'Mao B.');
      await advance(tester, const Duration(milliseconds: 300));
      await tapAndWait(tester, find.byTooltip('Celeste'));
      picker.path = '/tmp/avatar.jpg';
      await tapAndWait(tester, find.byType(AvatarEditor));
      await tapAndWait(tester, find.text('Elegir de la galería'));
      await tapAndWait(tester, find.text('Guardar'));

      final saved = profiles.profiles['uid-1']!;
      expect(saved.displayName, 'Mao B.');
      expect(saved.colorValue, 0xFF4FC3F7);
      expect(saved.photoUrl, FakeAvatarUploader.url);
      expect(saved.profileCompleted, isTrue);
      expect(uploader.uploads, ['/tmp/avatar.jpg']);
      expect(find.text('Perfil actualizado.'), findsOneWidget);
      expect(find.text(_home), findsNothing);
      expect(saveEnabled(tester), isFalse);
    });

    testWidgets('an empty name keeps the current one', (tester) async {
      await pumpScreen(tester);
      await tester.enterText(input('Nombres'), '  ');
      await tapAndWait(tester, find.byTooltip('Celeste'));
      await tapAndWait(tester, find.text('Guardar'));

      expect(profiles.profiles['uid-1']!.displayName, 'Mauricio Beltrán');
    });

    testWidgets('a name longer than 40 characters is rejected', (tester) async {
      await pumpScreen(tester);
      await tester.enterText(input('Nombres'), 'a' * 41);
      await advance(tester, const Duration(milliseconds: 300));
      await tapAndWait(tester, find.text('Guardar'));

      expect(find.text('Usa máximo 40 caracteres.'), findsOneWidget);
      expect(profiles.updates, isEmpty);
    });

    testWidgets('a failed upload shows the error and saves nothing', (
      tester,
    ) async {
      uploader.fail = true;
      await pumpScreen(tester);
      picker.path = '/tmp/avatar.jpg';
      await tapAndWait(tester, find.byType(AvatarEditor));
      await tapAndWait(tester, find.text('Elegir de la galería'));
      await tapAndWait(tester, find.text('Guardar'));

      expect(
        find.text(
          'No pudimos subir la foto. Revisa tu conexión e intenta de nuevo.',
        ),
        findsOneWidget,
      );
      expect(profiles.updates, isEmpty);
    });

    testWidgets('a failed write shows the error', (tester) async {
      profiles.updateError = Exception('permission-denied');
      await pumpScreen(tester);
      await tapAndWait(tester, find.byTooltip('Celeste'));
      await tapAndWait(tester, find.text('Guardar'));

      expect(
        find.text(
          'No pudimos guardar tu perfil. Revisa tu conexión e intenta de nuevo.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Cancelar drops the changes and goes to Inicio', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.enterText(input('Nombres'), 'Otro nombre');
      await tapAndWait(tester, find.byTooltip('Celeste'));
      await tapAndWait(tester, find.text('Cancelar'));

      expect(find.text(_home), findsOneWidget);
      expect(profiles.updates, isEmpty);
    });
  });

  group('change password', () {
    Future<void> openDialog(WidgetTester tester) async {
      await pumpScreen(tester);
      await tapAndWait(tester, find.text('Cambiar'));
      expect(find.text('Cambiar contraseña'), findsNWidgets(2));
    }

    Future<void> fill(
      WidgetTester tester, {
      String current = 'cuentasclaras',
      String next = 'nuevaclave',
      String? confirm,
    }) async {
      await tester.enterText(input('Contraseña actual'), current);
      await tester.enterText(input('Nueva contraseña'), next);
      await tester.enterText(
        input('Confirma la nueva contraseña'),
        confirm ?? next,
      );
      await advance(tester, const Duration(milliseconds: 300));
    }

    testWidgets('validates the fields before calling Firebase', (tester) async {
      await openDialog(tester);
      await fill(tester, confirm: 'otraclave');
      await tapAndWait(tester, find.text('Cambiar contraseña').last);

      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('changes the password and confirms it', (tester) async {
      await openDialog(tester);
      await fill(tester);
      await tapAndWait(tester, find.text('Cambiar contraseña').last);

      expect(auth.calls, ['changePassword:cuentasclaras:nuevaclave']);
      expect(find.text('Confirma la nueva contraseña'), findsNothing);
      expect(find.text('Contraseña actualizada.'), findsOneWidget);
    });

    testWidgets('a wrong current password stays in the popup', (tester) async {
      auth.failure = const InvalidCredentials();
      await openDialog(tester);
      await fill(tester);
      await tapAndWait(tester, find.text('Cambiar contraseña').last);

      expect(find.text('La contraseña actual no es correcta.'), findsOneWidget);
      expect(find.text('Confirma la nueva contraseña'), findsOneWidget);
    });

    testWidgets('Cancelar closes the popup without changes', (tester) async {
      await openDialog(tester);
      await tapAndWait(tester, find.text('Cancelar').last);

      expect(find.text('Confirma la nueva contraseña'), findsNothing);
      expect(find.text('Contraseña actualizada.'), findsNothing);
      expect(auth.calls, isEmpty);
    });
  });
}
