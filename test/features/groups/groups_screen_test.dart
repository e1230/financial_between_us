import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/widgets/fbu_pill_button.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/balances/data/balances_providers.dart';
import 'package:financial_between_us/features/groups/data/groups_providers.dart';
import 'package:financial_between_us/features/groups/data/selected_group_repository.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/group_failure.dart';
import 'package:financial_between_us/features/groups/presentation/group_detail_screen.dart';
import 'package:financial_between_us/features/groups/presentation/groups_screen.dart';
import 'package:financial_between_us/features/groups/presentation/widgets/group_card.dart';
import 'package:financial_between_us/features/home/data/home_providers.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/movements_fakes.dart';
import '../../support/group_fakes.dart';
import '../../support/home_fakes.dart';

const _uid = 'me';

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
  String owner = 'u2',
  int month = 1,
}) => Group(
  id: id,
  name: name,
  code: code,
  ownerUid: owner,
  memberUids: members,
  pendingUids: pending,
  createdAt: DateTime(2026, month),
);

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  late FakeGroupsRepository groups;
  late FakeSharedPreferencesAsync prefs;

  setUp(() {
    groups = FakeGroupsRepository();
    prefs = FakeSharedPreferencesAsync();
  });

  Future<void> pumpGroups(
    WidgetTester tester, {
    String initialLocation = AppRoutes.groups,
    Stream<List<Group>>? myGroups,
    Size size = const Size(360, 800),
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
            (ref) => Stream.value(_profile),
          ),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          groupsRepositoryProvider.overrideWithValue(groups),
          if (myGroups != null)
            myGroupsProvider.overrideWith((ref) => myGroups),
          selectedGroupRepositoryProvider.overrideWithValue(
            SelectedGroupRepository(prefs),
          ),
          homeActivityRepositoryProvider.overrideWithValue(
            FakeHomeActivityRepository(clock: () => DateTime(2026, 11, 25, 21)),
          ),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          movementsRepositoryProvider.overrideWithValue(
            FakeMovementsRepository(),
          ),
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
    if (initialLocation != AppRoutes.home) {
      router.push(initialLocation);
      await tester.pumpAndSettle();
    }
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder card(String name) => find.widgetWithText(GroupCard, name);

  Finder cardAction(String name, String tooltip) =>
      find.descendant(of: card(name), matching: find.byTooltip(tooltip));

  Finder confirm(String label) => find.widgetWithText(FbuPillButton, label);

  testWidgets('the menu option opens the page', (tester) async {
    await pumpGroups(tester, initialLocation: AppRoutes.menu);
    await tap(tester, find.text('Grupos'));
    expect(find.byType(GroupsScreen), findsOneWidget);

    await tap(tester, find.byTooltip('Volver'));
    expect(find.byType(GroupsScreen), findsNothing);
  });

  testWidgets('lists active and pending groups with their role', (
    tester,
  ) async {
    groups.groups.addAll([
      _group('g1', 'Fútbol', code: 'FUT-2345', owner: _uid),
      _group('g2', 'Asado', month: 2),
      _group('g3', 'Viaje', members: ['u2'], pending: [_uid]),
    ]);
    await pumpGroups(tester);

    expect(find.byType(GroupCard), findsNWidgets(3));
    expect(find.text('2 miembros · Administras'), findsOneWidget);
    expect(find.text('Código FUT-2345'), findsOneWidget);
    expect(find.text('1 miembro · Esperando aprobación'), findsOneWidget);
    expect(cardAction('Viaje', 'Cancelar solicitud'), findsOneWidget);
    expect(cardAction('Fútbol', 'Salir del grupo'), findsOneWidget);
    // The first active group is the one shown in the Home.
    expect(
      find.descendant(of: card('Fútbol'), matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
  });

  testWidgets('tapping a group opens its detail; pending ones do not', (
    tester,
  ) async {
    groups.groups.addAll([
      _group('g1', 'Fútbol'),
      _group('g3', 'Viaje', members: ['u2'], pending: [_uid], month: 2),
    ]);
    await pumpGroups(tester);

    await tap(tester, find.text('Viaje'));
    expect(find.byType(GroupDetailScreen), findsNothing);

    await tap(tester, find.text('Fútbol'));
    expect(find.byType(GroupDetailScreen), findsOneWidget);
  });

  testWidgets('without groups it invites to create or join', (tester) async {
    await pumpGroups(tester);
    expect(find.textContaining('Aún no estás en ningún grupo'), findsOneWidget);
    expect(find.text('Crear grupo'), findsOneWidget);
    expect(find.text('Unirme con un código'), findsOneWidget);

    await tap(tester, find.text('Unirme con un código'));
    expect(find.text('Unirme a un grupo'), findsOneWidget);
  });

  testWidgets('shows an error with a retry', (tester) async {
    await pumpGroups(
      tester,
      myGroups: Stream.error(const GroupNetworkFailure()),
    );
    expect(find.text('No pudimos cargar tus grupos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('leaving asks first; cancel keeps the group', (tester) async {
    groups.groups.addAll([
      _group('g1', 'Fútbol'),
      _group('g2', 'Asado', month: 2),
    ]);
    await pumpGroups(tester);

    await tap(tester, cardAction('Asado', 'Salir del grupo'));
    expect(find.text('¿Salir de Asado?'), findsOneWidget);
    expect(find.textContaining('necesitarás su código'), findsOneWidget);

    await tap(tester, find.text('Cancelar'));
    expect(find.text('¿Salir de Asado?'), findsNothing);
    expect(groups.calls, isEmpty);
    expect(card('Asado'), findsOneWidget);

    await tap(tester, cardAction('Asado', 'Salir del grupo'));
    await tap(tester, confirm('Salir del grupo'));
    expect(groups.calls, ['leave:g2']);
    expect(find.text('¿Salir de Asado?'), findsNothing);
    expect(card('Asado'), findsNothing);
    expect(card('Fútbol'), findsOneWidget);
  });

  testWidgets('the owner is told who keeps the group', (tester) async {
    groups.groups.addAll([
      _group('g1', 'Fútbol', owner: _uid),
      _group('g2', 'Solo yo', members: [_uid], owner: _uid, month: 2),
    ]);
    await pumpGroups(tester);

    await tap(tester, cardAction('Fútbol', 'Salir del grupo'));
    expect(find.textContaining('miembro más antiguo'), findsOneWidget);
    await tap(tester, confirm('Salir del grupo'));
    expect(groups.groups.firstWhere((g) => g.id == 'g1').ownerUid, 'u2');

    await tap(tester, cardAction('Solo yo', 'Salir del grupo'));
    expect(find.textContaining('el grupo se archivará'), findsOneWidget);
    await tap(tester, confirm('Salir del grupo'));
    expect(groups.groups.firstWhere((g) => g.id == 'g2').deletedAt, isNotNull);
    expect(find.byType(GroupCard), findsNothing);
  });

  testWidgets('a pending request can be withdrawn', (tester) async {
    groups.groups.add(_group('g3', 'Viaje', members: ['u2'], pending: [_uid]));
    await pumpGroups(tester);

    await tap(tester, cardAction('Viaje', 'Cancelar solicitud'));
    expect(find.text('¿Cancelar tu solicitud a Viaje?'), findsOneWidget);
    await tap(tester, confirm('Cancelar solicitud'));
    expect(groups.calls, ['leave:g3']);
    expect(find.byType(GroupCard), findsNothing);
  });

  testWidgets('a failed leave keeps the popup open with the error', (
    tester,
  ) async {
    groups.groups.add(_group('g1', 'Fútbol'));
    await pumpGroups(tester);

    groups.failure = const GroupNetworkFailure();
    await tap(tester, cardAction('Fútbol', 'Salir del grupo'));
    await tap(tester, confirm('Salir del grupo'));
    expect(find.text('Sin conexión. Revisa tu internet.'), findsOneWidget);
    expect(find.text('¿Salir de Fútbol?'), findsOneWidget);
    expect(card('Fútbol'), findsOneWidget);
  });

  testWidgets('no overflow at 130 % text on 360×640', (tester) async {
    groups.groups.addAll([
      _group('g1', 'Un nombre de grupo bastante largo', owner: _uid),
      _group('g2', 'Viaje', members: ['u2'], pending: [_uid], month: 2),
    ]);
    await pumpGroups(tester, size: const Size(360, 640), textScale: 1.3);
    expect(tester.takeException(), isNull);

    await tap(tester, cardAction('Viaje', 'Cancelar solicitud'));
    expect(tester.takeException(), isNull);
  });
}
