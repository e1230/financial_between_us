import 'dart:async';

import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:financial_between_us/features/profile/presentation/widgets/avatar_editor.dart';
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

  const newUser = UserProfile(
    uid: 'uid-1',
    displayName: 'mao',
    nickname: 'mao',
    email: 'mao@correo.com',
  );

  setUp(() {
    profiles = FakeUserProfileRepository(profiles: {'uid-1': newUser});
    uploader = FakeAvatarUploader();
    picker = FakeAvatarPicker();
  });

  Future<void> advance(WidgetTester tester, Duration duration) async {
    const frame = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += frame) {
      await tester.pump(frame);
    }
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    Stream<UserProfile?>? liveProfile,
  }) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.completeProfile,
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
          firebaseAuthProvider.overrideWithValue(
            FakeFirebaseAuth(currentUser: FakeUser()),
          ),
          userProfileRepositoryProvider.overrideWithValue(profiles),
          currentUserProfileProvider.overrideWith(
            (ref) => liveProfile ?? profiles.watch('uid-1'),
          ),
          avatarUploaderProvider.overrideWithValue(uploader),
          avatarPickerProvider.overrideWithValue(picker),
        ],
        child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
      ),
    );
    await advance(tester, const Duration(milliseconds: 800));
  }

  Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await advance(tester, const Duration(milliseconds: 800));
  }

  Future<void> pickPhoto(WidgetTester tester) async {
    picker.path = '/tmp/avatar.jpg';
    await tapAndWait(tester, find.byType(AvatarEditor));
    await tapAndWait(tester, find.text('Elegir de la galería'));
  }

  testWidgets('a stale null from the listener does not send the user back '
      'to choose a nickname', (tester) async {
    // Right after choosing a nickname the listener may still hold the
    // "no users/{uid}" snapshot while the document already exists.
    final live = StreamController<UserProfile?>();
    addTearDown(live.close);
    live.add(null);
    await pumpScreen(tester, liveProfile: live.stream);

    expect(find.text('Elige tu nombre de usuario'), findsNothing);
    expect(find.text('Tu color'), findsOneWidget);

    // The real snapshot arrives later and changes nothing.
    live.add(newUser);
    await advance(tester, const Duration(milliseconds: 300));
    expect(find.text('Tu color'), findsOneWidget);
  });

  testWidgets('without users/{uid} on the server it goes to choose one', (
    tester,
  ) async {
    profiles.profiles.clear();
    await pumpScreen(tester);
    expect(find.text('Elige tu nombre de usuario'), findsOneWidget);
  });

  testWidgets('shows the form with the letter avatar', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Completa tu perfil'), findsOneWidget);
    expect(find.text('Nombres'), findsOneWidget);
    expect(find.text('Tu color'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('skip completes the profile with the defaults', (tester) async {
    await pumpScreen(tester);
    await tapAndWait(tester, find.text('Omitir por ahora'));

    final saved = profiles.profiles['uid-1']!;
    expect(saved.profileCompleted, isTrue);
    expect(saved.displayName, 'mao');
    expect(saved.colorValue, UserProfile.defaultColorValue);
    expect(saved.photoUrl, isNull);
    expect(find.text(_home), findsOneWidget);
  });

  testWidgets('saves name, color and photo', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'Mauricio Beltrán');
    await advance(tester, const Duration(milliseconds: 300));
    await tapAndWait(tester, find.byTooltip('Celeste'));
    await pickPhoto(tester);
    await tapAndWait(tester, find.text('Guardar'));

    final saved = profiles.profiles['uid-1']!;
    expect(saved.profileCompleted, isTrue);
    expect(saved.displayName, 'Mauricio Beltrán');
    expect(saved.colorValue, 0xFF4FC3F7);
    expect(saved.photoUrl, FakeAvatarUploader.url);
    expect(uploader.uploads, ['/tmp/avatar.jpg']);
    expect(find.text(_home), findsOneWidget);
  });

  testWidgets('the chosen color previews as the accent', (tester) async {
    await pumpScreen(tester);
    await tapAndWait(tester, find.byTooltip('Celeste'));

    final button = find.text('Guardar');
    final theme = Theme.of(tester.element(button));
    expect(theme.colorScheme.primary, const Color(0xFF4FC3F7));
  });

  testWidgets('a failed upload keeps the user here', (tester) async {
    uploader.fail = true;
    await pumpScreen(tester);
    await pickPhoto(tester);
    await tapAndWait(tester, find.text('Guardar'));

    expect(
      find.text(
        'No pudimos subir la foto. Revisa tu conexión e intenta de nuevo.',
      ),
      findsOneWidget,
    );
    expect(profiles.profiles['uid-1']!.profileCompleted, isFalse);
    expect(find.text(_home), findsNothing);
  });

  testWidgets('a name longer than 40 characters is rejected', (tester) async {
    await pumpScreen(tester);
    await tester.enterText(find.byType(TextField), 'a' * 41);
    await tapAndWait(tester, find.text('Guardar'));

    expect(find.text('Usa máximo 40 caracteres.'), findsOneWidget);
    expect(profiles.profiles['uid-1']!.profileCompleted, isFalse);
  });

  testWidgets('the custom color opens the free picker', (tester) async {
    await pumpScreen(tester);
    await tapAndWait(tester, find.byTooltip('Color personalizado'));
    expect(find.bySemanticsLabel('Tono'), findsOneWidget);
    expect(find.bySemanticsLabel('Saturación y brillo'), findsOneWidget);
  });
}
