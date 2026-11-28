import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/widgets/fbu_pill_button.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/auth/presentation/widgets/fbu_text_field.dart';
import 'package:financial_between_us/features/balances/data/balances_providers.dart';
import 'package:financial_between_us/features/groups/data/groups_providers.dart';
import 'package:financial_between_us/features/groups/data/selected_group_repository.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/group_failure.dart';
import 'package:financial_between_us/features/groups/presentation/group_detail_screen.dart';
import 'package:financial_between_us/features/groups/presentation/groups_screen.dart';
import 'package:financial_between_us/features/groups/presentation/widgets/member_tile.dart';
import 'package:financial_between_us/features/home/data/home_providers.dart';
import 'package:financial_between_us/features/payment_accounts/data/payment_accounts_providers.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/member/member_accounts_sheet.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/payment_accounts_screen.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/ledger_builders.dart';
import '../../support/movements_fakes.dart';
import '../../support/fakes.dart';
import '../../support/group_fakes.dart';
import '../../support/payment_accounts_fakes.dart';
import '../../support/home_fakes.dart';

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
  List<String> admins = const [],
  List<String> members = const [_uid, 'ana', 'beto', 'carla'],
  List<String> pending = const [],
  bool requiresApproval = false,
  bool hasPassword = false,
}) => Group(
  id: 'g1',
  name: 'Fútbol',
  code: 'FUT-2345',
  ownerUid: owner,
  adminUids: [owner, ...admins],
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
  late FakeMovementsRepository balances;
  late FakePaymentAccountsRepository accounts;

  setUp(() {
    groups = FakeGroupsRepository();
    prefs = FakeSharedPreferencesAsync();
    accounts = FakePaymentAccountsRepository(
      accounts: sampleAccounts(),
      others: {'ana': sampleAccounts()},
    );
    balances = FakeMovementsRepository([
      debtOf('d1', 'ana', _uid, 32000, groupId: 'g1'),
      debtOf('d2', _uid, 'beto', 41500, groupId: 'g1'),
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
          movementsRepositoryProvider.overrideWithValue(balances),
          selectedGroupRepositoryProvider.overrideWithValue(
            SelectedGroupRepository(prefs),
          ),
          homeActivityRepositoryProvider.overrideWithValue(
            FakeHomeActivityRepository(clock: () => DateTime(2026, 11, 25, 21)),
          ),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          paymentAccountsRepositoryProvider.overrideWithValue(accounts),
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

  Finder options(String name) =>
      inRow(name, find.byTooltip('Opciones de $name'));

  /// Opens the options of [name] and picks [option].
  Future<void> choose(WidgetTester tester, String name, String option) async {
    await tap(tester, options(name));
    expect(find.text('¿Qué quieres hacer?'), findsOneWidget);
    await tap(tester, confirm(option));
  }

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
    expect(find.text('@juan · Administrador principal'), findsOneWidget);
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

    expect(find.byIcon(Icons.more_vert), findsNothing);
    expect(find.text('SOLICITUDES PENDIENTES'), findsOneWidget);
    expect(find.text('Dani Mora'), findsOneWidget);
    expect(find.text('Aprobar'), findsNothing);
    expect(find.text('Rechazar'), findsNothing);
  });

  testWidgets('the admin removes a member after confirming', (tester) async {
    groups.groups.add(_group());
    await pumpDetail(tester);

    expect(
      inRow('Juan Pérez (tú)', find.byIcon(Icons.more_vert)),
      findsNothing,
    );

    // Carla is even with everybody: no warning.
    await choose(tester, 'Carla Díaz', 'Eliminar del grupo');
    expect(find.text('¿Eliminar a Carla Díaz del grupo?'), findsOneWidget);
    expect(find.textContaining('saldos pendientes'), findsNothing);
    await tap(tester, find.text('Cancelar'));
    expect(groups.calls, isEmpty);

    // Ana owes money: warned, but allowed.
    await choose(tester, 'Ana Gómez', 'Eliminar del grupo');
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

    await choose(tester, 'Carla Díaz', 'Eliminar del grupo');
    groups.failure = const GroupNetworkFailure();
    await tap(tester, confirm('Eliminar del grupo'));
    expect(find.text('Sin conexión. Revisa tu internet.'), findsOneWidget);
    expect(find.text('¿Eliminar a Carla Díaz del grupo?'), findsOneWidget);
  });

  testWidgets('the admin promotes a member after confirming', (tester) async {
    groups.groups.add(_group());
    await pumpDetail(tester);

    await choose(tester, 'Beto Ruiz', 'Hacer administrador');
    expect(find.text('¿Hacer administrador a Beto Ruiz?'), findsOneWidget);
    await tap(tester, find.text('Cancelar'));
    expect(groups.calls, isEmpty);

    await choose(tester, 'Beto Ruiz', 'Hacer administrador');
    await tap(
      tester,
      find.widgetWithText(FbuPillButton, 'Hacer administrador'),
    );
    expect(groups.calls, ['promote:beto']);
    expect(find.text('@beto · Administrador'), findsOneWidget);
    // Admins are listed right after the owner.
    expect(
      tester.getTopLeft(row('Beto Ruiz')).dy,
      lessThan(tester.getTopLeft(row('Ana Gómez')).dy),
    );
  });

  testWidgets('the owner demotes another admin', (tester) async {
    groups.groups.add(_group(admins: ['ana']));
    await pumpDetail(tester);

    expect(find.text('@ana · Administrador'), findsOneWidget);
    await tap(tester, options('Ana Gómez'));
    // An admin cannot be promoted again.
    expect(confirm('Hacer administrador'), findsNothing);
    await tap(tester, confirm('Quitar como administrador'));
    expect(
      find.text('¿Quitarle la administración a Ana Gómez?'),
      findsOneWidget,
    );
    await tap(tester, confirm('Quitar como administrador'));
    expect(groups.calls, ['demote:ana']);
    expect(find.text('@ana · Miembro'), findsOneWidget);
  });

  testWidgets('another admin manages plain members only', (tester) async {
    groups.groups.add(
      _group(owner: 'ana', admins: [_uid, 'beto'], pending: ['dani']),
    );
    await pumpDetail(tester);

    expect(find.text('Administras este grupo'), findsOneWidget);
    expect(find.text('@ana · Administrador principal'), findsOneWidget);
    // Neither the owner nor another admin can be touched.
    expect(options('Ana Gómez'), findsNothing);
    expect(options('Beto Ruiz'), findsNothing);
    // Requests can be answered.
    expect(find.bySemanticsLabel('Aprobar a Dani Mora'), findsOneWidget);

    await tap(tester, options('Carla Díaz'));
    expect(confirm('Hacer administrador'), findsOneWidget);
    expect(confirm('Quitar como administrador'), findsNothing);
    expect(confirm('Eliminar del grupo'), findsOneWidget);
    await tap(tester, confirm('Hacer administrador'));
    await tap(tester, confirm('Hacer administrador'));
    expect(groups.calls, ['promote:carla']);
  });

  testWidgets('a member sees how many admins the group has', (tester) async {
    groups.groups.add(_group(owner: 'ana', admins: ['beto', 'carla']));
    await pumpDetail(tester);

    expect(find.text('Administran @ana y 2 más'), findsOneWidget);
  });

  group('editing the group', () {
    Finder field(String label) => find.widgetWithText(FbuTextField, label);
    Finder save() => confirm('Guardar cambios');

    testWidgets('only admins see "Editar grupo"', (tester) async {
      groups.groups.add(_group(owner: 'ana'));
      await pumpDetail(tester);
      expect(find.byTooltip('Editar grupo'), findsNothing);
    });

    testWidgets('another admin renames the group and asks for approval', (
      tester,
    ) async {
      groups.groups.add(_group(owner: 'ana', admins: [_uid]));
      await pumpDetail(tester);

      await tap(tester, find.byTooltip('Editar grupo'));
      expect(
        find.text('Los cambios aplican para todos los miembros.'),
        findsOneWidget,
      );
      // Nothing changed yet.
      expect(tester.widget<FbuPillButton>(save()).onPressed, isNull);

      await tester.enterText(field('Nombre del grupo'), 'ab');
      await tester.pump();
      await tap(tester, save());
      expect(find.text('Usa al menos 3 caracteres.'), findsOneWidget);
      expect(groups.calls, isEmpty);

      await tester.enterText(field('Nombre del grupo'), 'Fútbol 5');
      await tap(tester, find.text('Aprobar nuevos miembros'));
      await tap(tester, save());
      expect(groups.calls, ['update:g1']);
      expect(find.text('Editar grupo', skipOffstage: false), findsNothing);
      expect(find.text('Fútbol 5'), findsOneWidget);
      expect(find.text('Requiere aprobación'), findsOneWidget);
    });

    testWidgets('adding a password requires typing one', (tester) async {
      groups.groups.add(_group());
      await pumpDetail(tester);

      await tap(tester, find.byTooltip('Editar grupo'));
      expect(field('Contraseña'), findsNothing);
      await tap(tester, find.text('Pedir contraseña'));
      await tap(tester, save());
      expect(find.text('Este campo es obligatorio.'), findsOneWidget);

      await tester.enterText(field('Contraseña'), 'clave');
      await tap(tester, save());
      expect(groups.passwords['FUT-2345'], 'clave');
      expect(find.text('Con contraseña'), findsOneWidget);
    });

    testWidgets('the password can be changed or removed', (tester) async {
      groups
        ..groups.add(_group(hasPassword: true))
        ..passwords['FUT-2345'] = 'vieja';
      await pumpDetail(tester);

      await tap(tester, find.byTooltip('Editar grupo'));
      // An empty field keeps the current one.
      expect(find.text('Vacía para mantener la actual'), findsOneWidget);
      await tester.enterText(field('Nueva contraseña'), 'nueva');
      await tester.pump();
      await tap(tester, save());
      expect(groups.passwords['FUT-2345'], 'nueva');

      await tap(tester, find.byTooltip('Editar grupo'));
      await tap(tester, find.text('Pedir contraseña'));
      expect(field('Nueva contraseña'), findsNothing);
      await tap(tester, save());
      expect(groups.passwords, isEmpty);
      expect(find.text('Con contraseña'), findsNothing);
    });

    testWidgets('a failed save keeps the popup with the error', (tester) async {
      groups.groups.add(_group());
      await pumpDetail(tester);

      await tap(tester, find.byTooltip('Editar grupo'));
      await tap(tester, find.text('Aprobar nuevos miembros'));
      groups.failure = const GroupNetworkFailure();
      await tap(tester, save());
      expect(find.text('Sin conexión. Revisa tu internet.'), findsOneWidget);
      expect(save(), findsOneWidget);
    });

    testWidgets('no overflow at 130 % text on 360×640', (tester) async {
      groups.groups.add(_group(hasPassword: true));
      await pumpDetail(tester, size: const Size(360, 640), textScale: 1.3);
      await tap(tester, find.byTooltip('Editar grupo'));
      expect(tester.takeException(), isNull);
    });
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

  group('payment accounts of a member', () {
    List<String> copied(WidgetTester tester) {
      final log = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            log.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      return log;
    }

    testWidgets('tapping a member shows their accounts to copy', (
      tester,
    ) async {
      groups.groups.add(_group());
      await pumpDetail(tester);
      final log = copied(tester);

      await tap(tester, row('Ana Gómez'));
      expect(find.byType(MemberAccountsSheet), findsOneWidget);
      expect(find.text('Cuentas de Ana'), findsOneWidget);
      expect(find.text('300 123 4567'), findsOneWidget);
      expect(find.text('Toca una cuenta para copiarla.'), findsOneWidget);

      await tester.tap(find.text('Nequi personal'));
      await tester.pump();
      expect(log, ['3001234567']);
      expect(find.text('Copiado · 300 123 4567'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('a member without accounts', (tester) async {
      groups.groups.add(_group());
      accounts.others['beto'] = [];
      await pumpDetail(tester);
      await tap(tester, row('Beto Ruiz'));
      expect(find.text('Beto aún no tiene cuentas de pago.'), findsOneWidget);
    });

    testWidgets('accounts that cannot be read show an error', (tester) async {
      groups.groups.add(_group());
      accounts.denied.add('carla');
      await pumpDetail(tester);
      await tap(tester, row('Carla Díaz'));
      expect(find.text('No pudimos cargar sus cuentas.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('tapping my own row opens my accounts page', (tester) async {
      groups.groups.add(_group());
      await pumpDetail(tester);
      await tap(tester, row('Juan Pérez (tú)'));
      expect(find.byType(PaymentAccountsScreen), findsOneWidget);
    });
  });
}
