import 'package:financial_between_us/features/payment_accounts/domain/payment_account.dart';
import 'package:financial_between_us/features/payment_accounts/domain/payment_account_rules.dart';
import 'package:financial_between_us/features/payment_accounts/presentation/payment_accounts_strings.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Rules = PaymentAccountRules;

void main() {
  group('kindOf', () {
    test('maps each type and key type', () {
      expect(Rules.kindOf(null, null), ReferenceKind.none);
      expect(Rules.kindOf(PaymentAccountType.cash, null), ReferenceKind.none);
      expect(Rules.kindOf(PaymentAccountType.nequi, null), ReferenceKind.phone);
      expect(
        Rules.kindOf(PaymentAccountType.daviplata, null),
        ReferenceKind.phone,
      );
      expect(Rules.kindOf(PaymentAccountType.other, null), ReferenceKind.free);
      expect(Rules.kindOf(PaymentAccountType.breb, null), ReferenceKind.none);
      expect(
        Rules.kindOf(PaymentAccountType.breb, BrebKeyType.phone),
        ReferenceKind.phone,
      );
      expect(
        Rules.kindOf(PaymentAccountType.breb, BrebKeyType.email),
        ReferenceKind.email,
      );
      expect(
        Rules.kindOf(PaymentAccountType.breb, BrebKeyType.document),
        ReferenceKind.document,
      );
      expect(
        Rules.kindOf(PaymentAccountType.breb, BrebKeyType.alias),
        ReferenceKind.alias,
      );
    });
  });

  group('validateName', () {
    test('requires 1 to 40 characters once trimmed', () {
      expect(Rules.validateName('   '), NameError.empty);
      expect(Rules.validateName(' Nequi '), isNull);
      expect(Rules.validateName('a' * 40), isNull);
      expect(Rules.validateName('a' * 41), NameError.tooLong);
    });
  });

  group('validateReference', () {
    test('phone: 10 digits starting with 3', () {
      expect(
        Rules.validateReference(ReferenceKind.phone, ''),
        ReferenceError.empty,
      );
      expect(
        Rules.validateReference(ReferenceKind.phone, '300123'),
        ReferenceError.phoneLength,
      );
      expect(
        Rules.validateReference(ReferenceKind.phone, '6001234567'),
        ReferenceError.phonePrefix,
      );
      expect(
        Rules.validateReference(ReferenceKind.phone, '300 123 4567'),
        isNull,
      );
    });

    test('email', () {
      expect(
        Rules.validateReference(ReferenceKind.email, 'nombre@'),
        ReferenceError.email,
      );
      expect(
        Rules.validateReference(ReferenceKind.email, 'nombre@correo.com'),
        isNull,
      );
    });

    test('document: 6 to 10 digits', () {
      expect(
        Rules.validateReference(ReferenceKind.document, '12345'),
        ReferenceError.document,
      );
      expect(Rules.validateReference(ReferenceKind.document, '123456'), isNull);
      expect(
        Rules.validateReference(ReferenceKind.document, '1020304050'),
        isNull,
      );
      expect(
        Rules.validateReference(ReferenceKind.document, '10203040501'),
        ReferenceError.document,
      );
    });

    test('alias: @ plus 3 to 20 allowed characters', () {
      expect(
        Rules.validateReference(ReferenceKind.alias, 'mao1230'),
        ReferenceError.alias,
      );
      expect(
        Rules.validateReference(ReferenceKind.alias, '@ab'),
        ReferenceError.alias,
      );
      expect(
        Rules.validateReference(ReferenceKind.alias, '@mao.12_3-x'),
        isNull,
      );
      expect(
        Rules.validateReference(ReferenceKind.alias, '@${'a' * 21}'),
        ReferenceError.alias,
      );
    });

    test('other: at least 4 characters', () {
      expect(
        Rules.validateReference(ReferenceKind.free, 'abc'),
        ReferenceError.tooShort,
      );
      expect(
        Rules.validateReference(ReferenceKind.free, 'Ahorros 123'),
        isNull,
      );
    });

    test('nothing to validate without a reference', () {
      expect(Rules.validateReference(ReferenceKind.none, ''), isNull);
    });
  });

  test('normalizeReference keeps only digits for phones and documents', () {
    expect(
      Rules.normalizeReference(ReferenceKind.phone, '300 123-4567'),
      '3001234567',
    );
    expect(
      Rules.normalizeReference(ReferenceKind.document, '1.020.304'),
      '1020304',
    );
    expect(Rules.normalizeReference(ReferenceKind.alias, ' @x12 '), '@x12');
    expect(Rules.normalizeReference(ReferenceKind.none, 'abc'), '');
  });

  test('formatReference spaces 10-digit phones only', () {
    expect(
      Rules.formatReference(ReferenceKind.phone, '3001234567'),
      '300 123 4567',
    );
    expect(Rules.formatReference(ReferenceKind.phone, '300123'), '300123');
    expect(
      Rules.formatReference(ReferenceKind.document, '1020304050'),
      '1020304050',
    );
  });

  test('firstName takes the first word', () {
    expect(Rules.firstName('  Mauricio Beltrán '), 'Mauricio');
    expect(Rules.firstName(''), '');
  });

  test('fromWire is tolerant', () {
    expect(PaymentAccountType.fromWire('nequi'), PaymentAccountType.nequi);
    expect(PaymentAccountType.fromWire('crypto'), PaymentAccountType.other);
    expect(PaymentAccountType.fromWire(null), PaymentAccountType.other);
    expect(BrebKeyType.fromWire('alias'), BrebKeyType.alias);
    expect(BrebKeyType.fromWire('x'), isNull);
  });

  group('share text', () {
    test('includes the type, the formatted reference and the first name', () {
      const account = PaymentAccount(
        id: 'a',
        name: 'Nequi personal',
        type: PaymentAccountType.nequi,
        reference: '3001234567',
      );
      expect(
        PaymentAccountsStrings.shareText(account, 'Mauricio'),
        'Nequi · 300 123 4567 · Mauricio',
      );
    });

    test('cash says it receives cash', () {
      const account = PaymentAccount(
        id: 'a',
        name: 'Efectivo',
        type: PaymentAccountType.cash,
        reference: '',
      );
      expect(
        PaymentAccountsStrings.shareText(account, 'Mauricio'),
        'Recibo pago en efectivo · Mauricio',
      );
      expect(
        PaymentAccountsStrings.shareText(account, ''),
        'Recibo pago en efectivo',
      );
    });
  });

  test('error messages match the spec', () {
    expect(
      PaymentAccountsStrings.referenceError(ReferenceError.phoneLength),
      'Revisa el número: debe tener 10 dígitos',
    );
    expect(
      PaymentAccountsStrings.referenceError(ReferenceError.empty),
      'Escribe la referencia.',
    );
  });
}
