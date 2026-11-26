import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/widgets/fbu_pill_button.dart';
import 'package:financial_between_us/core/widgets/fbu_primary_button.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/groups/data/groups_providers.dart';
import 'package:financial_between_us/features/groups/data/selected_group_repository.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/home/data/home_activity_repository.dart';
import 'package:financial_between_us/features/home/data/home_providers.dart';
import 'package:financial_between_us/features/home/presentation/menu/avatar_menu_screen.dart';
import 'package:financial_between_us/features/home/presentation/widgets/ring_avatar.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:financial_between_us/features/profile/presentation/profile_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/group_fakes.dart';

const _uid = 'me';
const _welcome = 'WELCOME';

const _profile = UserProfile(
  uid: _uid,
  displayName: 'Juan Pérez',
  nickname: 'juan',
  email: 'juan@correo.com',
  colorValue: 0xFF9FA8DA,
  profileCompleted: true,
);

Group _group(
  String id,
  String name, {
  String code = 'AAA-2222',
  List<String> members = const [_uid, 'u2'],
  List<String> pending = const [],
  String owner = _uid,
  bool requiresApproval = false,
  bool hasPassword = false,
  int month = 1,
}) => Group(
  id: id,
  name: name,
  code: code,
  ownerUid: owner,
  memberUids: members,
  pendingUids: pending,
  requiresApproval: requiresApproval,
  hasPassword: hasPassword,
  createdAt: DateTime(2026, month),
);

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  late FakeGroupsRepository groups;
  late FakeSharedPreferencesAsync prefs;
  late FakeAuthRepository auth;
  late GoRouter router;
  String? clipboard;

  setUp(() {
    groups = FakeGroupsRepository();
    prefs = FakeSharedPreferencesAsync();
    auth = FakeAuthRepository();
    clipboard = null;
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(360, 800),
    double textScale = 1,
    bool disableAnimations = false,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );

    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.home,
      routes: [
        homeShellRoute(),
        ...overShellRoutes(),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const Scaffold(body: Text(_welcome)),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(FakeUser(uid: _uid)),
          ),
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(_profile),
          ),
          authRepositoryProvider.overrideWithValue(auth),
          groupsRepositoryProvider.overrideWithValue(groups),
          selectedGroupRepositoryProvider.overrideWithValue(
            SelectedGroupRepository(prefs),
          ),
          homeActivityRepositoryProvider.overrideWithValue(
            FakeHomeActivityRepository(clock: () => DateTime(2026, 11, 25, 21)),
          ),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
        ],
        child: MaterialApp.router(
          theme: AppTheme.withAccent(const Color(0xFF9FA8DA)),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              disableAnimations: disableAnimations,
            ),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder fieldInput(String label) => find.descendant(
    of: find
        .ancestor(of: find.text(label), matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder primaryButton(String label) =>
      find.widgetWithText(FbuPrimaryButton, label);

  group('without groups', () {
    testWidgets('invites to create or join and disables the group tabs', (
      tester,
    ) async {
      await pumpHome(tester);

      expect(find.text('Arma tu primer grupo'), findsOneWidget);
      expect(find.text('Crear un grupo'), findsOneWidget);
      expect(find.text('Unirme a un grupo'), findsOneWidget);
      expect(find.text('Sin grupo'), findsOneWidget);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Eventos')),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Agregar')),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );

      await tester.tap(find.text('Eventos'));
      await tester.pumpAndSettle();
      expect(find.text('Eventos (pendiente)'), findsNothing);
    });

    testWidgets('no overflow at 130 % text on 360×640', (tester) async {
      await pumpHome(tester, size: const Size(360, 640), textScale: 1.3);
      expect(tester.takeException(), isNull);
      await tap(tester, find.text('Crear un grupo'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('creating a group shows its code and makes it active', (
      tester,
    ) async {
      await pumpHome(tester);
      await tap(tester, find.text('Crear un grupo'));
      expect(find.text('Tus amigos se unirán con un código.'), findsOneWidget);

      await tester.enterText(fieldInput('Nombre del grupo'), 'Yo');
      await tap(tester, primaryButton('Crear grupo'));
      expect(find.text('Usa al menos 3 caracteres.'), findsOneWidget);
      expect(groups.calls, isEmpty);

      await tester.enterText(fieldInput('Nombre del grupo'), 'Los del parche');
      await tester.enterText(fieldInput('Contraseña (opcional)'), 'clave');
      await tap(tester, find.text('Aprobar nuevos miembros'));
      await tap(tester, primaryButton('Crear grupo'));

      expect(groups.calls, ['create:Los del parche']);
      expect(groups.groups.single.requiresApproval, isTrue);
      expect(find.text('Grupo creado'), findsOneWidget);
      expect(find.text('NUE-2345'), findsOneWidget);
      expect(
        find.text('También necesitarán la contraseña del grupo.'),
        findsOneWidget,
      );

      await tap(tester, find.bySemanticsLabel('Copiar código'));
      expect(clipboard, 'NUE-2345');
      expect(find.text('Copiado'), findsOneWidget);
      expect(find.text('Código copiado al portapapeles.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Copiar'), findsOneWidget);

      await tap(tester, primaryButton('Listo'));
      expect(find.text('Grupo creado'), findsNothing);
      expect(find.text('Hola, Juan'), findsOneWidget);
      expect(find.text('Los del parche'), findsOneWidget);
      expect(prefs.values[SelectedGroupRepository.selectedGroupIdKey], 'g1');
    });
  });

  group('joining', () {
    setUp(() {
      groups.groups.addAll([
        _group('mine', 'Mi grupo', code: 'MIG-2222'),
        _group(
          'open',
          'Grupo abierto',
          code: 'GAB-3333',
          members: const ['u2'],
          owner: 'u2',
        ),
        _group(
          'locked',
          'Grupo con clave',
          code: 'GCC-4444',
          members: const ['u2'],
          owner: 'u2',
          hasPassword: true,
        ),
        _group(
          'approval',
          'Grupo con aprobación',
          code: 'GCA-5555',
          members: const ['u2'],
          owner: 'u2',
          requiresApproval: true,
        ),
      ]);
      groups.passwords['GCC-4444'] = 'secreto';
    });

    Future<void> openJoin(WidgetTester tester) async {
      await tap(tester, find.bySemanticsLabel(RegExp('^Grupo actual')));
      await tap(tester, find.text('Unirme con un código'));
      expect(
        find.text('Escribe el código que te compartieron.'),
        findsOneWidget,
      );
    }

    Future<void> submitCode(WidgetTester tester, String code) async {
      await tester.enterText(fieldInput('Código del grupo'), code);
      await tap(tester, primaryButton('Unirme'));
    }

    testWidgets('reports unknown codes and groups the user is already in', (
      tester,
    ) async {
      await pumpHome(tester);
      await openJoin(tester);

      await submitCode(tester, 'zzz2222');
      expect(groups.calls.last, 'lookup:ZZZ-2222');
      expect(
        find.text('No encontramos un grupo con ese código.'),
        findsOneWidget,
      );

      await submitCode(tester, 'mig-2222');
      expect(find.text('Ya estás en este grupo.'), findsOneWidget);

      await submitCode(tester, 'mig');
      expect(find.text('El código es como LIQ-7K4P.'), findsOneWidget);
    });

    testWidgets('asks for the password and rejects a wrong one', (
      tester,
    ) async {
      await pumpHome(tester);
      await openJoin(tester);

      await submitCode(tester, 'GCC4444');
      expect(find.text('Contraseña del grupo'), findsOneWidget);
      expect(
        find.text('Grupo con clave pide una contraseña para entrar.'),
        findsOneWidget,
      );

      await tester.enterText(fieldInput('Contraseña'), 'otra');
      await tap(tester, primaryButton('Unirme'));
      expect(find.text('La contraseña no coincide.'), findsOneWidget);

      await tester.enterText(fieldInput('Contraseña'), 'secreto');
      await tap(tester, primaryButton('Unirme'));
      expect(find.text('Contraseña del grupo'), findsNothing);
      expect(find.text('Grupo con clave'), findsOneWidget); // the pill
      expect(
        prefs.values[SelectedGroupRepository.selectedGroupIdKey],
        'locked',
      );
    });

    testWidgets('a group with approval leaves the request pending', (
      tester,
    ) async {
      await pumpHome(tester);
      await openJoin(tester);

      await submitCode(tester, 'GCA-5555');
      expect(find.text('Solicitud enviada'), findsOneWidget);
      expect(
        find.textContaining('Un administrador de Grupo con aprobación'),
        findsOneWidget,
      );
      await tap(tester, primaryButton('Entendido'));

      // Still on the previous group; the pending one is disabled.
      expect(find.text('Mi grupo'), findsOneWidget);
      await tap(tester, find.bySemanticsLabel(RegExp('^Grupo actual')));
      expect(find.textContaining('Esperando aprobación'), findsOneWidget);
      await tester.tap(find.text('Grupo con aprobación'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(prefs.values[SelectedGroupRepository.selectedGroupIdKey], isNull);
    });

    testWidgets('a group without approval or password is joined directly', (
      tester,
    ) async {
      await pumpHome(tester);
      await openJoin(tester);

      await submitCode(tester, 'gab 3333');
      expect(find.text('Unirme a un grupo'), findsNothing);
      expect(find.text('Grupo abierto'), findsOneWidget);
    });
  });

  group('with groups', () {
    setUp(() {
      groups.groups.addAll([
        _group('a', 'Primer grupo', month: 1),
        _group('b', 'Segundo grupo', owner: 'u2', month: 2),
      ]);
    });

    testWidgets('shows greeting, legend, actions and movements', (
      tester,
    ) async {
      await pumpHome(tester);

      expect(find.text('Hola, Juan'), findsOneWidget);
      expect(find.text('Primer grupo'), findsOneWidget);
      expect(find.text(r'$ 1.642.000'), findsOneWidget); // paid in 6 months
      expect(find.text(r'$ 162.000'), findsOneWidget);
      expect(find.text(r'$ 86.500'), findsWidgets);
      expect(find.text('Agregar ingreso'), findsOneWidget);
      expect(find.text('@ana te pagó'), findsOneWidget);
      expect(find.text(r'+$ 32.000'), findsOneWidget);
      expect(find.text('−\$ 248.000'), findsOneWidget);
      expect(
        find.text('Andrés Carne de Res · Ayer · 6 personas'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp(r'Pagado: \$ 1\.642\.000')),
        findsOneWidget,
      );
    });

    testWidgets('the period chips change the chart', (tester) async {
      await pumpHome(tester);
      expect(find.text('Nov'), findsOneWidget);
      await tap(tester, find.text('Semana'));
      expect(find.text('Nov'), findsNothing);
      expect(find.text('D'), findsOneWidget);
    });

    testWidgets('the selector switches and remembers the group', (
      tester,
    ) async {
      await pumpHome(tester);
      await tap(tester, find.bySemanticsLabel(RegExp('^Grupo actual')));
      expect(find.text('TUS GRUPOS'), findsOneWidget);
      expect(find.text('2 miembros · Administras'), findsOneWidget);
      expect(find.text('2 miembros'), findsOneWidget);

      await tap(tester, find.text('Segundo grupo').last);
      expect(find.text('TUS GRUPOS'), findsNothing);
      expect(find.text('Segundo grupo'), findsOneWidget);
      expect(prefs.values[SelectedGroupRepository.selectedGroupIdKey], 'b');
    });

    testWidgets('the + opens the popover and its options', (tester) async {
      await pumpHome(tester);
      await tap(tester, find.bySemanticsLabel('Agregar'));
      expect(find.text('Agregar evento'), findsOneWidget);
      expect(find.text('Agregar movimiento'), findsOneWidget);

      await tap(tester, find.text('Agregar movimiento'));
      expect(find.text('Agregar movimiento (pendiente)'), findsOneWidget);
    });

    testWidgets('back from another tab returns to Inicio', (tester) async {
      await pumpHome(tester);
      await tap(tester, find.text('Saldos'));
      expect(find.text('Saldos (pendiente)'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Hola, Juan'), findsOneWidget);
    });

    testWidgets('the avatar opens the menu, which signs out after asking', (
      tester,
    ) async {
      await pumpHome(tester);
      await tap(tester, find.bySemanticsLabel('Abrir menú'));

      expect(find.byType(AvatarMenuScreen), findsOneWidget);
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('@juan'), findsOneWidget);
      expect(find.text('Primer grupo y 1 más'), findsOneWidget);
      expect(find.text('Financial Between Us · versión 1.0.0'), findsOneWidget);

      await tap(tester, find.text('Cerrar sesión'));
      expect(find.text('¿Cerrar sesión?'), findsOneWidget);
      await tap(tester, find.text('Cancelar'));
      expect(auth.calls, isEmpty);

      await tap(tester, find.text('Cerrar sesión'));
      await tap(tester, find.widgetWithText(FbuPillButton, 'Cerrar sesión'));
      expect(auth.calls, ['signOut']);
      expect(find.text(_welcome), findsOneWidget);
    });

    testWidgets('the Perfil tab shows the profile settings', (tester) async {
      await pumpHome(tester);
      await tap(tester, find.text('Perfil'));

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Tu color'), findsOneWidget);
      expect(find.text('juan@correo.com'), findsOneWidget);
    });

    testWidgets('the profile row of the menu opens the Perfil tab', (
      tester,
    ) async {
      await pumpHome(tester);
      await tap(tester, find.bySemanticsLabel('Abrir menú'));
      await tap(tester, find.text('@juan'));

      expect(find.byType(AvatarMenuScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Cancelar goes back to Inicio.
      await tap(tester, find.text('Cancelar'));
      expect(find.text('Hola, Juan'), findsOneWidget);
    });

    testWidgets('from the menu the avatar flies to the profile, not home', (
      tester,
    ) async {
      await pumpHome(tester);
      await tap(tester, find.bySemanticsLabel('Abrir menú'));
      await tester.tap(find.text('@juan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 225));

      // Mid-flight it grows from 64 toward the 96 dp profile avatar.
      final sizes = [
        for (final e in find.byType(RingAvatar).evaluate())
          tester.getSize(find.byWidget(e.widget)).width,
      ];
      expect(sizes.any((w) => w > 64 && w < 96), isTrue, reason: '$sizes');
      expect(sizes.any((w) => w < 64), isFalse, reason: '$sizes');

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('the header avatar shows again after the menu went to '
        'another tab', (tester) async {
      await pumpHome(tester);
      for (final option in ['@juan', 'Saldos']) {
        await tap(tester, find.bySemanticsLabel('Abrir menú'));
        await tap(tester, find.text(option).last);
        expect(find.byType(AvatarMenuScreen), findsNothing);

        // Back to Inicio.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Hola, Juan'), findsOneWidget);
        expect(
          find.byType(RingAvatar),
          findsOneWidget,
          reason: 'after $option the avatar was left as an empty placeholder',
        );
      }
    });

    testWidgets('the avatar flies from 44 to 64 dp into the menu', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.bySemanticsLabel('Abrir menú'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 225));
      final sizes = [
        for (final e in find.byType(RingAvatar).evaluate())
          tester.getSize(find.byWidget(e.widget)).width,
      ];
      expect(sizes.any((w) => w > 44 && w < 64), isTrue, reason: '$sizes');
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(RingAvatar)).width, 64);
    });

    testWidgets('back closes the menu', (tester) async {
      await pumpHome(tester);
      await tap(tester, find.bySemanticsLabel('Abrir menú'));
      expect(find.byType(AvatarMenuScreen), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(AvatarMenuScreen), findsNothing);
      expect(find.text('Hola, Juan'), findsOneWidget);
    });

    testWidgets('no overflow at 130 % text on 360×640', (tester) async {
      await pumpHome(tester, size: const Size(360, 640), textScale: 1.3);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Le debes a @pedro').hitTestable(), findsOneWidget);
    });

    testWidgets('works without animations', (tester) async {
      await pumpHome(tester, disableAnimations: true);
      expect(find.text('Hola, Juan'), findsOneWidget);
      await tap(tester, find.bySemanticsLabel('Abrir menú'));
      expect(find.byType(AvatarMenuScreen), findsOneWidget);
    });
  });
}
