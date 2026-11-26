import 'package:financial_between_us/core/widgets/fbu_pill_button.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/form/payment_account_form_screen.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/payment_accounts_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/payment_accounts_fakes.dart';
import 'accounts_harness.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es_CO'));

  late FakePaymentAccountsRepository repository;

  setUp(() => repository = FakePaymentAccountsRepository());

  /// Opens the form from the list's "+", as in the app.
  Future<void> openForm(
    WidgetTester tester, {
    Size? size,
    double? scale,
  }) async {
    await pumpAccounts(
      tester,
      repository: repository,
      size: size ?? const Size(360, 800),
      textScale: scale ?? 1,
    );
    await tapAndSettle(tester, find.byTooltip('Agregar cuenta'));
  }

  Finder field(String label) => find
      .ancestor(of: find.text(label), matching: find.byType(GestureDetector))
      .first;

  Finder input(String label) =>
      find.descendant(of: field(label), matching: find.byType(TextField));

  bool saveEnabled(WidgetTester tester) =>
      tester
          .widget<FbuPillButton>(
            find.ancestor(
              of: find.text('Guardar'),
              matching: find.byType(FbuPillButton),
            ),
          )
          .onPressed !=
      null;

  Finder tile(String label) => find.bySemanticsLabel(label);

  testWidgets('starts empty with "Guardar" disabled', (tester) async {
    await openForm(tester);
    expect(find.text('Nueva cuenta'), findsOneWidget);
    expect(find.text('Elige un tipo'), findsOneWidget);
    expect(find.text('Primero elige un tipo'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('creates a Nequi account', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, tile('Nequi').last);
    // The name is filled in from the type.
    expect(tester.widget<TextField>(input('Nombre')).controller!.text, 'Nequi');
    expect(find.text('Número de celular'), findsOneWidget);

    await tester.enterText(input('Número de celular'), '300');
    await tapAndSettle(tester, input('Nombre'));
    expect(
      find.text('Revisa el número: debe tener 10 dígitos'),
      findsOneWidget,
    );
    expect(saveEnabled(tester), isFalse);

    await tester.enterText(input('Número de celular'), '3001234567');
    await tester.pumpAndSettle();
    expect(saveEnabled(tester), isTrue);
    await tapAndSettle(tester, find.text('Guardar'));

    expect(repository.calls, ['create:Nequi']);
    expect(repository.accounts.single.reference, '3001234567');
    expect(find.byType(PaymentAccountsScreen), findsOneWidget);
    expect(find.text('Cuenta guardada'), findsOneWidget);
    await settleTimers(tester);
  });

  testWidgets('a phone must start with 3', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, tile('Daviplata').last);
    await tester.enterText(input('Número de celular'), '6001234567');
    await tapAndSettle(tester, find.text('Guardar'));
    expect(find.text('Revisa el número: debe empezar por 3'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('Bre-B asks for the key type first', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, tile('Bre-B').last);
    expect(find.text('Tipo de llave'), findsOneWidget);
    expect(find.text('Elige el tipo de llave'), findsOneWidget);
    expect(tester.widget<TextField>(input('Llave')).enabled, isFalse);

    await tapAndSettle(tester, tile('Alfanumérica'));
    expect(find.text('Empieza por @. Ej. @tullave'), findsOneWidget);
    await tester.enterText(input('Llave'), 'mao');
    await tapAndSettle(tester, input('Nombre'));
    expect(
      find.text('La llave debe empezar por @ y tener de 3 a 20 caracteres.'),
      findsOneWidget,
    );

    await tester.enterText(input('Llave'), '@mao1230');
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.text('Guardar'));
    expect(repository.accounts.single.reference, '@mao1230');
    expect(repository.accounts.single.name, 'Llave Bre-B');
    await settleTimers(tester);
  });

  testWidgets('cash hides the reference', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, tile('Efectivo').last);
    expect(find.text('Primero elige un tipo'), findsNothing);
    expect(find.text('Referencia'), findsNothing);
    expect(saveEnabled(tester), isTrue);
  });

  testWidgets('"Otro" keeps the name empty', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, tile('Otro').last);
    expect(tester.widget<TextField>(input('Nombre')).controller!.text, '');
    expect(find.text('Número o referencia'), findsOneWidget);
  });

  testWidgets('closing with changes asks first', (tester) async {
    await openForm(tester);
    await tester.enterText(input('Nombre'), 'Mi cuenta');
    await tapAndSettle(tester, find.byTooltip('Cerrar'));
    expect(find.text('¿Descartar los cambios?'), findsOneWidget);

    await tapAndSettle(tester, find.text('Seguir editando'));
    expect(find.byType(PaymentAccountFormScreen), findsOneWidget);

    await tapAndSettle(tester, find.byTooltip('Cerrar'));
    await tapAndSettle(tester, find.text('Descartar'));
    expect(find.byType(PaymentAccountFormScreen), findsNothing);
  });

  testWidgets('closing without changes does not ask', (tester) async {
    await openForm(tester);
    await tapAndSettle(tester, find.byTooltip('Cerrar'));
    expect(find.byType(PaymentAccountFormScreen), findsNothing);
  });

  testWidgets('fits 130 % text on 360×640', (tester) async {
    await openForm(tester, size: const Size(360, 640), scale: 1.3);
    await tapAndSettle(tester, tile('Bre-B').last);
    expect(tester.takeException(), isNull);
  });
}
