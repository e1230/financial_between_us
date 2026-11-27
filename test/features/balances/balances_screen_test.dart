import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/balances/domain/movement_failure.dart';
import 'package:financial_between_us/features/balances/presentation/person/person_balance_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../support/movements_fakes.dart';
import 'balances_harness.dart';

/// Fails to load any group.
class _BrokenMovements extends FakeMovementsRepository {
  @override
  Stream<List<LedgerMovement>> watchGroup(String groupId) =>
      Stream.error(const MovementNetworkFailure());
}

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  testWidgets('summary, sections in order and the settled people', (
    tester,
  ) async {
    await pumpBalances(tester);

    expect(find.text('Saldos'), findsWidgets);
    expect(find.text('Low IQ Group'), findsWidgets);
    expect(find.text(r'+$ 75.500'), findsOneWidget);
    expect(find.text('A tu favor en Low IQ Group'), findsOneWidget);
    expect(find.text(r'$ 162.000'), findsOneWidget);
    expect(find.text(r'$ 86.500'), findsOneWidget);
    expect(find.text('3 personas'), findsOneWidget);
    expect(find.text('2 personas'), findsOneWidget);
    expect(
      find.bySemanticsLabel(r'Te deben $ 162.000 y debes $ 86.500'),
      findsOneWidget,
    );

    expect(find.text('TE DEBEN · 3'), findsOneWidget);
    expect(find.text('DEBES · 2'), findsOneWidget);
    expect(find.text('A PAZ Y SALVO · 3'), findsOneWidget);
    // Biggest first.
    final santi = tester.getTopLeft(find.text('Santiago Ruiz')).dy;
    final juliana = tester.getTopLeft(find.text('Juliana Pardo')).dy;
    final nico = tester.getTopLeft(find.text('Nicolás Gómez')).dy;
    expect(santi, lessThan(juliana));
    expect(juliana, lessThan(nico));
    expect(find.text('@santi · 3 pendientes'), findsOneWidget);
    expect(find.text(r'$ 72.000'), findsOneWidget);

    // "A paz y salvo" starts collapsed.
    expect(find.text('Felipe Castro'), findsNothing);
    await tapAndSettle(
      tester,
      find.text('Personas sin saldo pendiente contigo'),
    );
    expect(find.text('Felipe Castro'), findsOneWidget);
    expect(find.text('Ocultar'), findsOneWidget);
    expect(find.textContaining('@feli · último:'), findsOneWidget);
    expect(find.text('@dani · sin movimientos'), findsOneWidget);
    expect(
      find.text(
        'Aparecen aquí cuando no tienen nada pendiente contigo en '
        'Low IQ Group.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('"Todos los grupos" adds every group up', (tester) async {
    await pumpBalances(tester);
    await tapAndSettle(tester, find.text('Todos los grupos'));

    expect(find.text(r'+$ 112.500'), findsOneWidget);
    expect(find.text('A tu favor en 3 grupos'), findsOneWidget);
    expect(find.text('TE DEBEN · 4'), findsOneWidget);
    expect(find.text(r'$ 90.000'), findsOneWidget);
    expect(find.text('@santi · 2 grupos'), findsOneWidget);
    expect(find.text('@tomas · Viaje a Villa de Leyva'), findsOneWidget);
    expect(find.text(r'$ 60.000'), findsOneWidget); // Valentina, two groups.
  });

  testWidgets('everything even shows "Todo en orden"', (tester) async {
    await pumpBalances(tester, movements: FakeMovementsRepository());
    expect(find.text(r'$ 0'), findsWidgets);
    expect(find.text('Sin saldo en Low IQ Group'), findsOneWidget);
    expect(find.text('Todo en orden'), findsOneWidget);
    expect(
      find.text('Nadie te debe y no le debes a nadie en Low IQ Group.'),
      findsOneWidget,
    );
    expect(find.text('A PAZ Y SALVO · 8'), findsOneWidget);
    expect(find.text('TE DEBEN · 0'), findsNothing);
  });

  testWidgets('an error offers to retry', (tester) async {
    await pumpBalances(tester, movements: _BrokenMovements());
    expect(find.text('No pudimos cargar los saldos.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('a row opens the detail of that person', (tester) async {
    await pumpBalances(tester);
    await tapAndSettle(tester, find.text('Santiago Ruiz'));
    expect(find.byType(PersonBalanceScreen), findsOneWidget);
    expect(find.text('@santi · Low IQ Group'), findsOneWidget);
  });

  testWidgets('rows are announced with their balance', (tester) async {
    await pumpBalances(tester);
    expect(
      find.bySemanticsLabel(r'Santiago Ruiz, te debe $ 72.000, 3 pendientes'),
      findsOneWidget,
    );
  });

  testWidgets('no overflow at 130 % text on 360×640', (tester) async {
    await pumpBalances(tester, size: const Size(360, 640), textScale: 1.3);
    expect(tester.takeException(), isNull);
    await tester.drag(find.text('Santiago Ruiz'), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('works without animations', (tester) async {
    await pumpBalances(tester, reduceMotion: true);
    expect(find.text(r'+$ 75.500'), findsOneWidget);
    await tapAndSettle(tester, find.text('Todos los grupos'));
    expect(find.text(r'+$ 112.500'), findsOneWidget);
  });
}
