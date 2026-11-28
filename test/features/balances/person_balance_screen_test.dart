import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/balances/presentation/sheets/movement_detail_sheet.dart';
import 'package:financial_between_us/features/balances/presentation/sheets/register_payment_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/movements_fakes.dart';
import 'balances_harness.dart';

String _person(String uid, [String group = sampleGroupId]) =>
    AppRoutes.personBalanceFor(uid, group);

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  group('someone who owes the user', () {
    testWidgets('balance, pending items oldest first and history', (
      tester,
    ) async {
      await pumpBalances(tester, location: _person('santi'));

      expect(find.text('Santiago Ruiz'), findsOneWidget);
      expect(find.text('@santi · Low IQ Group'), findsOneWidget);
      expect(find.text('Te debe'), findsOneWidget);
      expect(find.text(r'$ 72.000'), findsOneWidget);
      expect(find.text('3 pendientes · desde el 18 nov'), findsOneWidget);
      expect(find.text('PENDIENTES · 3'), findsOneWidget);

      final taxi = tester.getTopLeft(find.text('Taxi al aeropuerto')).dy;
      final bolos = tester.getTopLeft(find.text('Bolos en Unicentro').first).dy;
      expect(taxi, lessThan(bolos));
      expect(find.text(r'de $ 26.000'), findsOneWidget);
      expect(find.text(r'$ 16.000'), findsOneWidget);
      expect(find.text('pagaste tú'), findsWidgets);
      expect(
        find.bySemanticsLabel(
          RegExp(
            r'Bolos en Unicentro, evento, .*falta \$ 16\.000 de \$ 26\.000',
          ),
        ),
        findsOneWidget,
      );

      // History: the payment Santi registered.
      expect(find.text('Santiago te abonó'), findsOneWidget);
      expect(find.text(r'+$ 10.000'), findsOneWidget);
      expect(find.text('Registrar deuda'), findsOneWidget);
      expect(find.text('Registrar pago'), findsOneWidget);
    });

    testWidgets('"Recordarle" shares the amount and the user\'s accounts', (
      tester,
    ) async {
      final h = await pumpBalances(tester, location: _person('santi'));
      await tapAndSettle(tester, find.text('Recordarle'));
      expect(h.share.shared.single, contains(r'tienes $ 72.000 pendientes'));
      expect(h.share.shared.single, contains('en Low IQ Group'));
      expect(h.share.shared.single, contains('Nequi 300 123 4567'));
      expect(h.share.shared.single, contains('Bre-B @mao1230'));
      expect(h.share.shared.single, isNot(contains('Efectivo')));
    });

    testWidgets('"Ver todo" shows the filters and months', (tester) async {
      await pumpBalances(tester, location: _person('santi'));
      await tapAndSettle(tester, find.text('Ver todo'));
      expect(find.text('NOVIEMBRE'), findsOneWidget);
      expect(find.text('Pagos'), findsOneWidget);
      await tapAndSettle(tester, find.text('Pagos'));
      expect(find.text('Santiago te abonó'), findsOneWidget);
      expect(find.text('Taxi al aeropuerto'), findsOneWidget); // pending row
      expect(find.textContaining('Inicio del historial'), findsOneWidget);
    });
  });

  testWidgets('someone the user owes shows their accounts to copy', (
    tester,
  ) async {
    final h = await pumpBalances(tester, location: _person('carlosm'));
    expect(find.text('Le debes'), findsOneWidget);
    expect(find.text(r'$ 41.500'), findsWidgets);
    expect(find.text('Recordarle'), findsNothing);
    expect(find.text('CUENTAS DE CARLOS'), findsOneWidget);
    expect(find.text('311 222 3344'), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Copiar Nequi'));
    expect(h.copied, ['3112223344']);
    expect(find.text('Copiado · 311 222 3344'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  testWidgets('opposite debts cancel each other in the pending items', (
    tester,
  ) async {
    LedgerMovement debt(String id, String from, String to, int amount, int d) =>
        LedgerMovement(
          id: id,
          groupId: sampleGroupId,
          type: LedgerMovementType.debt,
          debtorUid: from,
          creditorUid: to,
          amount: amount,
          kind: DebtKind.direct,
          concept: id == 'cine' ? 'Cine' : 'Préstamo',
          date: DateTime(2026, 11, d, 12),
          createdBy: sampleMe,
          seenBy: const [sampleMe],
        );
    await pumpBalances(
      tester,
      location: _person('nico'),
      movements: FakeMovementsRepository([
        ...sampleMovements().where((m) => !m.involves('nico')),
        debt('cine', sampleMe, 'nico', 5000, 20),
        debt('prestamo', 'nico', sampleMe, 10000, 22),
      ]),
    );

    expect(find.text('Te debe'), findsOneWidget);
    expect(find.text('PENDIENTES · 1'), findsOneWidget);
    expect(find.textContaining('compensada'), findsWidgets);
    expect(find.text(r'de $ 10.000'), findsOneWidget);
  });

  testWidgets('someone even shows only "Registrar deuda"', (tester) async {
    await pumpBalances(tester, location: _person('feli'));
    expect(find.text('A paz y salvo'), findsWidgets);
    expect(find.text('No tienen nada pendiente.'), findsOneWidget);
    expect(find.text('Registrar deuda'), findsOneWidget);
    expect(find.text('Registrar pago'), findsNothing);
  });

  group('registering', () {
    testWidgets('a full payment settles everything', (tester) async {
      final h = await pumpBalances(tester, location: _person('santi'));
      await tapAndSettle(tester, find.text('Registrar pago'));

      expect(find.byType(RegisterPaymentSheet), findsOneWidget);
      expect(find.text('Santiago te pagó'), findsOneWidget);
      expect(find.text(r'Todo · $ 72.000'), findsOneWidget);
      expect(find.text('SE APLICA A'), findsOneWidget);
      expect(find.text('¿A CUÁL DE TUS CUENTAS TE PAGÓ?'), findsOneWidget);

      await tapAndSettle(tester, find.text(r'Registrar pago · $ 72.000'));
      expect(h.movements.calls.single, startsWith('registerPayments:'));
      final payment = h.movements.movementsOf(sampleGroupId).last;
      expect(payment.amount, 72000);
      expect(payment.account?.name, 'Nequi personal');
      expect(
        {for (final a in payment.appliedTo) a.targetId: a.amount},
        {'taxi': 15000, 'bolos': 16000, 'carne': 41000},
      );
      expect(find.text('A paz y salvo'), findsWidgets);
      expect(find.text(r'Pago registrado · $ 72.000'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('a partial payment goes to the oldest items first', (
      tester,
    ) async {
      final h = await pumpBalances(tester, location: _person('santi'));
      await tapAndSettle(tester, find.text('Registrar pago'));

      await tester.enterText(find.byType(TextField), '20000');
      await tester.pumpAndSettle();
      expect(find.text(r'$ 20.000'), findsOneWidget);
      expect(find.text(r'abona $ 5.000'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '99000');
      await tester.pumpAndSettle();
      expect(
        find.text(r'No puede ser mayor que lo pendiente ($ 72.000).'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), '20000');
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text(r'Registrar pago · $ 20.000'));
      final payment = h.movements.movementsOf(sampleGroupId).last;
      expect(
        {for (final a in payment.appliedTo) a.targetId: a.amount},
        {'taxi': 15000, 'bolos': 5000},
      );
      expect(find.text(r'$ 52.000'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('a payment with an image uploads it first', (tester) async {
      final h = await pumpBalances(tester, location: _person('carlosm'));
      await tapAndSettle(tester, find.text('Registrar pago'));
      expect(find.text('Le pagaste a Carlos'), findsOneWidget);
      expect(find.text('¿A CUÁL DE SUS CUENTAS LE PAGASTE?'), findsOneWidget);
      expect(find.text('Efectivo'), findsOneWidget);
      expect(
        find.text(
          'Se aplica de inmediato. Carlos puede rechazarlo si no le llegó.',
        ),
        findsOneWidget,
      );

      await tapAndSettle(tester, find.text('Adjuntar imagen'));
      await tapAndSettle(tester, find.text('Elegir de la galería'));
      expect(find.text('recibo.jpg'), findsOneWidget);
      expect(find.text('240 KB · toca para ver'), findsOneWidget);

      await tapAndSettle(tester, find.text(r'Registrar pago · $ 41.500'));
      expect(h.uploader.uploads, ['$sampleGroupId:/tmp/recibo.jpg']);
      final payment = h.movements.movementsOf(sampleGroupId).last;
      expect(payment.debtorUid, sampleMe);
      expect(payment.attachment?.url, 'https://example.com/recibo.jpg');
      expect(payment.account?.name, 'Nequi');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('if the image fails to upload nothing is saved', (
      tester,
    ) async {
      final h = await pumpBalances(tester, location: _person('carlosm'));
      h.uploader.fail = true;
      await tapAndSettle(tester, find.text('Registrar pago'));
      await tapAndSettle(tester, find.text('Adjuntar imagen'));
      await tapAndSettle(tester, find.text('Tomar foto'));
      await tapAndSettle(tester, find.text(r'Registrar pago · $ 41.500'));
      expect(
        find.text('No pudimos subir la imagen. Intenta de nuevo.'),
        findsOneWidget,
      );
      expect(h.movements.calls, isEmpty);
    });

    testWidgets('a debt needs an amount and a concept', (tester) async {
      final h = await pumpBalances(tester, location: _person('feli'));
      await tapAndSettle(tester, find.text('Registrar deuda'));
      expect(find.text('Con Felipe Castro'), findsOneWidget);
      expect(find.text('Felipe me debe'), findsOneWidget);
      expect(find.text('Sin evento · deuda directa'), findsOneWidget);
      expect(find.textContaining('Hoy, '), findsOneWidget);

      await tapAndSettle(tester, find.text('Registrar deuda').last);
      expect(find.text('Escribe un monto.'), findsOneWidget);
      expect(find.text('Escribe un concepto.'), findsOneWidget);
      expect(h.movements.calls, isEmpty);

      await tester.enterText(find.byType(TextField).first, '15000');
      await tester.enterText(find.byType(TextField).last, 'Taxi');
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.text('Yo le debo'));
      await tapAndSettle(tester, find.text('Registrar deuda').last);

      final debt = h.movements.movementsOf(sampleGroupId).last;
      expect(debt.isDebt, isTrue);
      expect(debt.kind, DebtKind.direct);
      expect(debt.debtorUid, sampleMe);
      expect(debt.creditorUid, 'feli');
      expect(debt.amount, 15000);
      expect(debt.concept, 'Taxi');
      expect(find.text('Deuda registrada'), findsOneWidget);
      expect(find.text('Le debes'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });

  group('movements registered by someone else', () {
    testWidgets('the recipient can reject them with a reason', (tester) async {
      final repo = FakeMovementsRepository([
        ...sampleMovements(),
        LedgerMovement(
          id: 'nico-pago',
          groupId: sampleGroupId,
          type: LedgerMovementType.payment,
          debtorUid: 'nico',
          creditorUid: sampleMe,
          amount: 31500,
          appliedTo: const [
            PaymentApplication(targetId: 'karaoke', amount: 31500),
          ],
          date: DateTime(2026, 11, 25, 19),
          createdBy: 'nico',
          seenBy: const ['nico'],
        ),
      ]);
      final h = await pumpBalances(
        tester,
        location: _person('nico'),
        movements: repo,
      );
      expect(find.text('A paz y salvo'), findsWidgets);

      await tapAndSettle(tester, find.text('Nicolás te pagó'));
      expect(find.byType(MovementDetailSheet), findsOneWidget);
      expect(find.text('Nicolás registró un pago'), findsOneWidget);
      expect(find.text('Noche de karaoke'), findsWidgets);
      expect(
        find.text(
          r'Si no te llegó, recházalo y Nicolás volverá a deberte $ 31.500.',
        ),
        findsOneWidget,
      );
      expect(h.movements.calls, ['markSeen:nico-pago']);

      await tapAndSettle(tester, find.text('Rechazar'));
      expect(find.text('¿Rechazar el pago de Nicolás?'), findsOneWidget);
      await tapAndSettle(tester, find.text('Monto equivocado'));
      await tapAndSettle(tester, find.text('Rechazar').last);

      expect(h.movements.calls.last, 'reject:nico-pago:wrong_amount');
      expect(
        find.text('Pago rechazado · Nicolás ya fue avisado'),
        findsOneWidget,
      );
      expect(find.text('Te debe'), findsOneWidget);
      expect(find.text(r'$ 31.500'), findsWidgets);
      expect(find.textContaining('Lo rechazaste'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('rechazado')), findsWidgets);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    LedgerMovement nicoPayment() => LedgerMovement(
      id: 'nico-pago',
      groupId: sampleGroupId,
      type: LedgerMovementType.payment,
      debtorUid: 'nico',
      creditorUid: sampleMe,
      amount: 31500,
      appliedTo: const [PaymentApplication(targetId: 'karaoke', amount: 31500)],
      date: DateTime(2026, 11, 25, 19),
      createdBy: 'nico',
      seenBy: const ['nico'],
    );

    testWidgets('a notification opens the movement it is about', (
      tester,
    ) async {
      final h = await pumpBalances(
        tester,
        location: AppRoutes.personBalanceFor(
          'nico',
          sampleGroupId,
          movementId: 'nico-pago',
        ),
        movements: FakeMovementsRepository([
          ...sampleMovements(),
          nicoPayment(),
        ]),
      );

      expect(find.byType(MovementDetailSheet), findsOneWidget);
      expect(find.text('Nicolás registró un pago'), findsOneWidget);
      expect(find.text('¿Rechazar el pago de Nicolás?'), findsNothing);
      expect(h.movements.calls, ['markSeen:nico-pago']);
    });

    testWidgets('"Rechazar" of a notification opens the reject dialog', (
      tester,
    ) async {
      final h = await pumpBalances(
        tester,
        location: AppRoutes.personBalanceFor(
          'nico',
          sampleGroupId,
          movementId: 'nico-pago',
          reject: true,
        ),
        movements: FakeMovementsRepository([
          ...sampleMovements(),
          nicoPayment(),
        ]),
      );

      expect(find.text('¿Rechazar el pago de Nicolás?'), findsOneWidget);
      await tapAndSettle(tester, find.text('No me llegó'));
      await tapAndSettle(tester, find.text('Rechazar').last);
      expect(h.movements.calls.last, 'reject:nico-pago:not_received');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('"Rechazar" of a movement already rejected only shows it', (
      tester,
    ) async {
      await pumpBalances(
        tester,
        location: AppRoutes.personBalanceFor(
          'nico',
          sampleGroupId,
          movementId: 'nico-pago',
          reject: true,
        ),
        movements: FakeMovementsRepository([
          ...sampleMovements(),
          nicoPayment().copyWith(
            status: MovementStatus.rejected,
            rejectedBy: sampleMe,
            rejectedAt: DateTime(2026, 11, 25, 20),
            rejectReason: RejectReason.notReceived,
          ),
        ]),
      );

      expect(find.byType(MovementDetailSheet), findsOneWidget);
      expect(find.text('¿Rechazar el pago de Nicolás?'), findsNothing);
    });

    testWidgets('the author cannot reject, only delete', (tester) async {
      final h = await pumpBalances(tester, location: _person('santi'));
      await tapAndSettle(tester, find.text('Taxi al aeropuerto'));
      expect(find.text('Registraste una deuda'), findsOneWidget);
      expect(find.text('Rechazar'), findsNothing);
      await tapAndSettle(tester, find.text('Eliminar'));
      expect(find.text('¿Eliminar este movimiento?'), findsOneWidget);
      await tapAndSettle(tester, find.text('Eliminar').last);
      expect(h.movements.calls, ['delete:taxi']);
      expect(find.text('Movimiento eliminado'), findsOneWidget);
      expect(find.text(r'$ 57.000'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('a movement where the user is the author of a payment '
        'received shows Eliminar', (tester) async {
      await pumpBalances(tester, location: _person('feli'));
      await tapAndSettle(tester, find.text('Felipe te pagó'));
      expect(find.text('Registraste un pago'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });
  });

  testWidgets('the full history loads more pages while scrolling', (
    tester,
  ) async {
    final repo = FakeMovementsRepository([
      for (var i = 0; i < 45; i++)
        LedgerMovement(
          id: 'h$i',
          groupId: sampleGroupId,
          type: LedgerMovementType.debt,
          debtorUid: 'dani',
          creditorUid: sampleMe,
          amount: 1000,
          concept: 'Gasto $i',
          date: DateTime(2026, 11, 1).add(Duration(hours: i)),
          createdBy: sampleMe,
          seenBy: const [sampleMe, 'dani'],
        ),
    ]);
    await pumpBalances(tester, location: _person('dani'), movements: repo);
    // Only the live first page so far.
    expect(repo.fetchedPages, 0);
    expect(find.text('Gasto 44'), findsWidgets);

    await tapAndSettle(tester, find.text('Ver todo'));
    for (
      var i = 0;
      i < 6 && find.textContaining('Inicio del historial').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -3000),
      );
      await tester.pumpAndSettle();
    }
    expect(repo.fetchedPages, 2);
    expect(find.text('Gasto 0'), findsWidgets); // pending + history
    expect(find.textContaining('Inicio del historial'), findsOneWidget);
  });

  testWidgets('no overflow at 130 % text on 360×640', (tester) async {
    await pumpBalances(
      tester,
      location: _person('santi'),
      size: const Size(360, 640),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
    await tester.drag(find.text('Te debe'), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tapAndSettle(tester, find.text('Registrar pago'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('works without animations', (tester) async {
    await pumpBalances(
      tester,
      location: _person('santi', 'all'),
      reduceMotion: true,
    );
    expect(find.text('@santi · 2 grupos'), findsOneWidget);
    expect(find.text(r'$ 90.000'), findsOneWidget);
  });
}
