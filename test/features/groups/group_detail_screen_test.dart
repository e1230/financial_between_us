import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/widgets/fbu_pill_button.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/balances/data/balances_providers.dart';
import 'package:financial_between_us/features/balances/domain/debt.dart';
import 'package:financial_between_us/features/groups/data/groups_providers.dart';
import 'package:financial_between_us/features/groups/data/selected_group_repository.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/group_failure.dart';
import 'package:financial_between_us/features/groups/presentation/group_detail_screen.dart';
import 'package:financial_between_us/features/groups/presentation/groups_screen.dart';
import 'package:financial_between_us/features/groups/presentation/widgets/member_tile.dart';
import 'package:financial_between_us/features/home/data/home_activity_repository.dart';
import 'package:financial_between_us/features/home/data/home_providers.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/balances_fakes.dart';
import '../../support/fakes.dart';
import '../../support/group_fakes.dart';

const _uid = 'me';

UserProfile _profile(String uid, String name, String nickname) => UserProfile(
  uid: uid,
  displayName: name,
  nickname: nickname,
  email: '$nickname@correo.com',
  colorValue: 0xFF9FA8DA,
  profileCompleted: true,
);

final _profiles = {
  _uid: _profile(_uid, 'Juan Pérez', 'juan'),
  'ana': _profile('ana', 'Ana Gómez', 'ana'),
  'beto': _profile('beto', 'Beto Ruiz', 'beto'),
  'carla': _profile('carla', 'Carla Díaz', 'carla'),
  'dani': _profile('dani', 'Dani Mora', 'dani'),
};

Group _group({
  String owner = _uid,
  List<String> members = const [_uid, 'ana', 'beto', 'carla'],
  List<String> pending = const [],
  bool requiresApproval = false,
  bool hasPassword = false,
}) => Group(
  id: 'g1',
  name: 'Fútbol',
  code: 'FUT-2345',
  ownerUid: owner,
  memberUids: members,
  pendingUids: pending,
  requiresApproval: requiresApproval,
  hasPassword: hasPassword,
  createdAt: DateTime(2026, 1, 15),
);

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  late FakeGroupsRepository groups;
  late FakeSharedPreferencesAsync prefs;
  late FixedBalancesRepository balances;

  setUp(() {
    groups = FakeGroupsRepository();
    prefs = FakeSharedPreferencesAsync();
    balances = FixedBalancesRepository([
      const Debt(fromUid: 'ana', toUid: _uid, amount: 32000),
      const Debt(fromUid: _uid, toUid: 'beto', amount: 41500),
    ]);
  });

  Future<void> pumpDetail(
    WidgetTester tester, {
    Size size = const Size(360, 800),
    double textScale = 1,
    String location = '/groups/g1',
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );

    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.home,
      routes: [homeShellRoute(), ...overShellRoutes()],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(FakeUser(uid: _uid)),
          ),
          currentUserProfileProvider.overrideWith(
            (ref) => Stream.value(_profiles[_uid]),
          ),
          userProfileRepositoryProvider.overrideWithValue(
            FakeUserProfileRepository(profiles: _profiles),
          ),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          groupsRepositoryProvider.overrideWithValue(groups),
          balancesRepositoryProvider.overrideWithValue(balances),
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
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.push(AppRoutes.groups);
    await tester.pumpAndSettle();
    if (location != AppRoutes.groups) {
      router.push(location);
      await tester.pumpAndSettle();
    }
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder row(String name) => find.widgetWithText(MemberTile, name);

  Finder inRow(String name, Finder matching) =>
      find.descendant(of: row(name), matching: matching);

  Finder confirm(String label) => find.widgetWithText(FbuPillButton, label);

  testWidgets('opens from the group list', (tester) async {
    groups.groups.add(_group());
    await pumpDetail(tester, location: AppRoutes.groups);

    await tap(tester, find.text('Fútbol'));
    expect(find.byType(GroupDetailScreen), findsOneWidget);
    await tap(tester, find.byTooltip('Volver'));
    expect(find.byType(GroupDetailScreen), findsNothing);
    expect(find.byType(GroupsScreen), findsOneWidget);
  });

  testWidgets('shows the group summary', (tester) async {
    groups.groups.add(
      _group(owner: 'ana', requiresApproval: true, hasPassword: true),
    );
    await pumpDetail(tester);

    expect(find.text('Fútbol'), findsOneWidget);
    expect(find.text('4 miembros'), findsOneWidget);
    expect(find.text('Creado el 15 ene 2026'), findsOneWidget);
    expect(find.text('Administra @ana'), findsOneWidget);
    expect(find.text('Requiere aprobación'), findsOneWidget);
    expect(find.text('Con contraseña'), findsOneWidget);
    expect(find.text('FUT-2345'), findsOneWidget);
    // The only group is the one shown in the Home.
    expect(find.text('Se muestra en Inicio'), findsOneWidget);
  });

  testWidgets('lists members with role, since when and the balance', (
    tester,
  ) async {
    groups
      ..groups.add(_group())
      ..joinedAt['ana'] = DateTime(2026, 2, 3);
    await pumpDetail(tester);

    expect(find.byType(MemberTile), findsNWidgets(4));
    expect(find.text('Juan Pérez (tú)'), findsOneWidget);
    expect(find.text('@juan · Administrador'), findsOneWidget);
    expect(find.text('@ana · Miembro'), findsOneWidget);
    expect(
      inRow('Ana Gómez', find.text('Desde el 3 feb 2026')),
      findsOneWidget,
    );

    expect(
      inRow('Ana Gómez', find.bySemanticsLabel('Te debe \$ 32.000')),
      findsOneWidget,
    );
    expect(
      inRow('Beto Ruiz', find.bySemanticsLabel('Debes \$ 41.500')),
      findsOneWidget,
    );
    expect(inRow('Carla Díaz', find.text('Están a mano')), findsOneWidget);
    expect(inRow('Juan Pérez (tú)', find.byType(BalanceLabel)), findsNothing);
    // The admin is listed first.
    expect(
      tester.getTopLeft(row('Juan Pérez (tú)')).dy,
      lessThan(tester.getTopLeft(row('Ana Gómez')).dy),
    );
  });

  testWidgets('a plain member sees no admin actions', (tester) async {
    groups.groups.add(_group(owner: 'ana', pending: ['dani']));
    await pumpDetail(tester);

    expect(find.byTooltip('Eliminar del grupo'), findsNothing);
    expect(find.text('SOLICITUDES PENDIENTES'), findsOneWidget);
    expect(find.text('Dani Mora'), findsOneWidget);
    expect(find.text('Aprobar'), findsNothing);
    expect(find.text('Rechazar'), findsNothing);
  });

  testWidgets('the admin removes a member after confirming', (tester) async {
    groups.groups.add(_group());
    await pumpDetail(tester);

    expect(
      inRow('Juan Pérez (tú)', find.byTooltip('Eliminar del grupo')),
      findsNothing,
    );

    // Carla is even with everybody: no warning.
    await tap(
      tester,
      inRow('Carla Díaz', find.byTooltip('Eliminar del grupo')),
    );
    expect(find.text('¿Eliminar a Carla Díaz del grupo?'), findsOneWidget);
    expect(find.textContaining('saldos pendientes'), findsNothing);
    await tap(tester, find.text('Cancelar'));
    expect(groups.calls, isEmpty);

    // Ana owes money: warned, but allowed.
    await tap(tester, inRow('Ana Gómez', find.byTooltip('Eliminar del grupo')));
    expect(find.textContaining('saldos pendientes'), findsOneWidget);
    await tap(tester, confirm('Eliminar del grupo'));
    expect(groups.calls, ['remove:ana']);
    expect(row('Ana Gómez'), findsNothing);
    expect(find.text('3 miembros'), findsOneWidget);
  });

  testWidgets('a failed removal keeps the popup with the error', (
    tester,
  ) async {
    groups.groups.add(_group());
    await pumpDetail(tester);

    groups.failure = const GroupNetworkFailure();
    await tap(
      tester,
      inRow('Carla Díaz', find.byTooltip('Eliminar del grupo')),
    );
    await tap(tester, confirm('Eliminar del grupo'));
    expect(find.text('Sin conexión. Revisa tu internet.'), findsOneWidget);
    expect(find.text('¿Eliminar a Carla Díaz del grupo?'), findsOneWidget);
  });

  testWidgets('the admin approves and rejects requests', (tester) async {
    groups.groups.add(_group(pending: ['dani', 'carla'], members: [_uid]));
    await pumpDetail(tester);

    expect(find.text('SOLICITUDES PENDIENTES'), findsOneWidget);
    await tap(tester, find.bySemanticsLabel('Aprobar a Dani Mora'));
    expect(groups.calls, ['approve:dani']);
    expect(row('Dani Mora'), findsOneWidget);
    expect(
      inRow('Dani Mora', find.text('Desde el 25 nov 2026')),
      findsOneWidget,
    );

    await tap(tester, find.bySemanticsLabel('Rechazar a Carla Díaz'));
    expect(find.text('¿Rechazar la solicitud de Carla Díaz?'), findsOneWidget);
    await tap(tester, confirm('Rechazar'));
    expect(groups.calls.last, 'reject:carla');
    expect(find.text('SOLICITUDES PENDIENTES'), findsNothing);
    expect(find.text('Carla Díaz'), findsNothing);
  });

  testWidgets('a failed approval shows a banner', (tester) async {
    groups.groups.add(_group(pending: ['dani']));
    await pumpDetail(tester);

    groups.failure = const GroupNetworkFailure();
    await tap(tester, find.bySemanticsLabel('Aprobar a Dani Mora'));
    expect(find.text('Sin conexión. Revisa tu internet.'), findsOneWidget);
    expect(find.text('SOLICITUDES PENDIENTES'), findsOneWidget);
  });

  testWidgets('"Mostrar en Inicio" selects the group', (tester) async {
    groups.groups.addAll([
      _group(),
      Group(
        id: 'g0',
        name: 'Asado',
        code: 'ASA-2345',
        ownerUid: 'ana',
        memberUids: const [_uid, 'ana'],
        createdAt: DateTime(2025),
      ),
    ]);
    await pumpDetail(tester);

    await tap(tester, find.text('Mostrar en Inicio'));
    expect(prefs.values[SelectedGroupRepository.selectedGroupIdKey], 'g1');
    expect(find.text('Se muestra en Inicio'), findsOneWidget);
  });

  testWidgets('leaving from the detail goes back to the list', (tester) async {
    groups.groups.add(_group(owner: 'ana'));
    await pumpDetail(tester);

    await tap(tester, confirm('Salir del grupo'));
    expect(find.text('¿Salir de Fútbol?'), findsOneWidget);
    // The popup's button (the page has one with the same label below it).
    await tap(tester, confirm('Salir del grupo').last);
    expect(groups.calls, ['leave:g1']);
    expect(find.byType(GroupDetailScreen), findsNothing);
    expect(find.byType(GroupsScreen), findsOneWidget);
  });

  testWidgets('says so when the user is no longer in the group', (
    tester,
  ) async {
    await pumpDetail(tester);
    expect(find.text('Ya no haces parte de este grupo.'), findsOneWidget);
    await tap(tester, find.text('Volver'));
    expect(find.byType(GroupsScreen), findsOneWidget);
  });

  testWidgets('no overflow at 130 % text on 360×640', (tester) async {
    groups.groups.add(
      _group(pending: ['dani'], requiresApproval: true, hasPassword: true),
    );
    await pumpDetail(tester, size: const Size(360, 640), textScale: 1.3);
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
