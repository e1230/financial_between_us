import 'dart:async';

import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/widgets/pending_screen.dart';
import 'package:financial_between_us/features/home/presentation/home_strings.dart';
import 'package:financial_between_us/features/payment_accounts/domain/payment_account.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/form/payment_account_form_screen.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/payment_accounts_screen.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/sheet/payment_account_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/payment_accounts_fakes.dart';
import 'accounts_harness.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  late FakePaymentAccountsRepository repository;
  late FakeShareService share;

  setUp(() {
    repository = FakePaymentAccountsRepository(accounts: sampleAccounts());
    share = FakeShareService();
  });

  Finder row(String name) =>
      find.ancestor(of: find.text(name), matching: find.byType(InkWell)).first;

  testWidgets('the card button of the Home opens the accounts', (tester) async {
    await pumpAccounts(
      tester,
      repository: repository,
      location: AppRoutes.home,
    );
    await tapAndSettle(tester, find.byTooltip(HomeStrings.accounts));
    expect(find.byType(PaymentAccountsScreen), findsOneWidget);
    expect(find.byType(PendingScreen), findsNothing);
  });

  testWidgets('"Cuentas" of the avatar menu opens the accounts', (
    tester,
  ) async {
    await pumpAccounts(
      tester,
      repository: repository,
      location: AppRoutes.menu,
    );
    await tapAndSettle(tester, find.text(HomeStrings.accounts));
    expect(find.byType(PaymentAccountsScreen), findsOneWidget);
  });

  testWidgets('lists the accounts with formatted references', (tester) async {
    await pumpAccounts(tester, repository: repository);
    expect(find.text('Cuentas de pago'), findsOneWidget);
    expect(
      find.text('Compártelas cuando un amigo te vaya a pagar.'),
      findsOneWidget,
    );
    expect(find.text('Nequi personal'), findsOneWidget);
    expect(find.text('300 123 4567'), findsOneWidget);
    expect(find.text('@mao1230'), findsOneWidget);
    expect(find.text('310 987 6543'), findsOneWidget);
    expect(find.text('Pago en efectivo'), findsOneWidget);
    expect(
      find.text('Mantén presionada una cuenta para copiar su referencia.'),
      findsOneWidget,
    );
  });

  testWidgets('without accounts shows the empty state', (tester) async {
    await pumpAccounts(tester, repository: FakePaymentAccountsRepository());
    expect(find.text('Aún no tienes cuentas'), findsOneWidget);
    expect(find.text('Agregar cuenta'), findsOneWidget);
    await tapAndSettle(tester, find.text('Agregar cuenta'));
    expect(find.text('Nueva cuenta'), findsOneWidget);
  });

  testWidgets('shows an error with "Reintentar"', (tester) async {
    await pumpAccounts(
      tester,
      repository: repository,
      accounts: Stream.error(Exception('offline')),
    );
    expect(find.text('No pudimos cargar tus cuentas.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('shows skeleton rows while loading', (tester) async {
    final controller = StreamController<List<PaymentAccount>>();
    addTearDown(controller.close);
    await pumpAccounts(
      tester,
      repository: repository,
      accounts: controller.stream,
    );
    expect(find.bySemanticsLabel('Cargando tus cuentas'), findsOneWidget);
  });

  testWidgets('a long press copies the raw reference and vibrates', (
    tester,
  ) async {
    final log = await pumpAccounts(tester, repository: repository);
    await tester.longPress(row('Nequi personal'));
    await tester.pump();
    expect(log.copied, ['3001234567']);
    expect(log.vibrations, 1);
    expect(find.text('Copiado · 300 123 4567'), findsOneWidget);
    await settleTimers(tester);
    expect(find.text('Copiado · 300 123 4567'), findsNothing);
  });

  testWidgets('cash has nothing to copy', (tester) async {
    final log = await pumpAccounts(tester, repository: repository);
    await tester.longPress(row('Efectivo'));
    await tester.pump();
    expect(log.copied, isEmpty);
    expect(log.vibrations, 0);
    expect(find.text('Efectivo no tiene referencia'), findsOneWidget);
    await settleTimers(tester);
  });

  testWidgets('rows offer "Copiar referencia" to screen readers', (
    tester,
  ) async {
    final log = await pumpAccounts(tester, repository: repository);
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label?.startsWith('Nequi personal, Nequi') == true,
      ),
    );
    final actions = semantics.properties.customSemanticsActions!;
    expect(actions.keys.single.label, 'Copiar referencia');
    actions.values.single();
    await tester.pump();
    expect(log.copied, ['3001234567']);
    await settleTimers(tester);
  });

  testWidgets('the detail copies and shares', (tester) async {
    final log = await pumpAccounts(
      tester,
      repository: repository,
      share: share,
    );
    await tapAndSettle(tester, row('Nequi personal'));
    expect(find.byType(PaymentAccountSheet), findsOneWidget);
    expect(find.text('NÚMERO DE CELULAR'), findsOneWidget);

    await tester.tap(find.text('Copiar'));
    await tester.pumpAndSettle();
    expect(log.copied, ['3001234567']);
    expect(find.text('Copiado'), findsOneWidget);
    await settleTimers(tester);
    expect(find.text('Copiar'), findsOneWidget);

    await tapAndSettle(tester, find.text('Compartir'));
    expect(share.shared, ['Nequi · 300 123 4567 · Juan']);
  });

  testWidgets('the Bre-B detail shows the key chip', (tester) async {
    await pumpAccounts(tester, repository: repository);
    await tapAndSettle(tester, row('Llave Bre-B'));
    expect(find.text('Llave · Alfanumérica'), findsOneWidget);
  });

  testWidgets('the cash detail only shares', (tester) async {
    await pumpAccounts(tester, repository: repository, share: share);
    await tapAndSettle(tester, row('Efectivo'));
    expect(find.text('Copiar'), findsNothing);
    expect(
      find.text(
        'No hay número que copiar. Compártelo para avisar que recibes '
        'efectivo.',
      ),
      findsOneWidget,
    );
    await tapAndSettle(tester, find.text('Compartir'));
    expect(share.shared, ['Recibo pago en efectivo · Juan']);
  });

  testWidgets('deletes from the menu after confirming', (tester) async {
    await pumpAccounts(tester, repository: repository);
    await tapAndSettle(tester, row('Nequi personal'));
    await tapAndSettle(tester, find.byTooltip('Más opciones'));
    await tapAndSettle(tester, find.text('Eliminar'));
    expect(find.text('¿Eliminar “Nequi personal”?'), findsOneWidget);

    await tapAndSettle(tester, find.widgetWithText(TextButton, 'Eliminar'));
    expect(repository.calls, contains('delete:a1'));
    expect(find.byType(PaymentAccountSheet), findsNothing);
    expect(find.text('Cuenta eliminada'), findsOneWidget);
    expect(find.text('Nequi personal'), findsNothing);
    await settleTimers(tester);
  });

  testWidgets('edits from the menu', (tester) async {
    await pumpAccounts(tester, repository: repository);
    await tapAndSettle(tester, row('Nequi personal'));
    await tapAndSettle(tester, find.byTooltip('Más opciones'));
    await tapAndSettle(tester, find.text('Editar'));
    expect(find.byType(PaymentAccountFormScreen), findsOneWidget);
    expect(find.text('Editar cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Nequi de la casa');
    await tapAndSettle(tester, find.text('Guardar'));
    expect(repository.calls, contains('update:a1'));
    expect(find.text('Cambios guardados'), findsOneWidget);
    expect(find.text('Nequi de la casa'), findsOneWidget);
    await settleTimers(tester);
  });

  testWidgets('the + stops at 10 accounts', (tester) async {
    final many = FakePaymentAccountsRepository(
      accounts: [
        for (var i = 0; i < 10; i++)
          PaymentAccount(
            id: 'x$i',
            name: 'Cuenta $i',
            type: PaymentAccountType.other,
            reference: 'Ref $i 1234',
            createdAt: DateTime(2026, 1, i + 1),
          ),
      ],
    );
    await pumpAccounts(tester, repository: many);
    await tester.tap(find.byTooltip('Agregar cuenta'));
    await tester.pump();
    expect(find.text('Llegaste al máximo de 10 cuentas'), findsOneWidget);
    expect(find.byType(PaymentAccountFormScreen), findsNothing);
    await settleTimers(tester);
  });

  testWidgets('fits 412×915 and 130 % text on 360×640', (tester) async {
    await pumpAccounts(
      tester,
      repository: repository,
      size: const Size(412, 915),
    );
    expect(tester.takeException(), isNull);

    await pumpAccounts(
      tester,
      repository: repository,
      size: const Size(360, 640),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
    await tapAndSettle(tester, row('Nequi personal'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('works with reduced motion', (tester) async {
    await pumpAccounts(tester, repository: repository, reduceMotion: true);
    await tapAndSettle(tester, row('Nequi personal'));
    expect(find.byType(PaymentAccountSheet), findsOneWidget);
  });
}
