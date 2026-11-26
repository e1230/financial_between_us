import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_between_us/features/payment_accounts/data/payment_account_mapper.dart';
import 'package:financial_between_us/features/payment_accounts/data/payment_accounts_repository.dart';
import 'package:financial_between_us/features/payment_accounts/domain/payment_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a Bre-B account', () {
    final account = PaymentAccountMapper.fromFirestore('a1', {
      'name': 'Llave Bre-B',
      'type': 'breb',
      'keyType': 'alias',
      'reference': '@mao1230',
      'createdAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 2)),
      'deletedAt': null,
    });
    expect(account.type, PaymentAccountType.breb);
    expect(account.keyType, BrebKeyType.alias);
    expect(account.reference, '@mao1230');
    expect(account.createdAt, DateTime(2026, 1, 2));
    expect(account.deletedAt, isNull);
  });

  test('an unknown type is "other" and partial documents do not crash', () {
    final account = PaymentAccountMapper.fromFirestore('a', {'type': 'crypto'});
    expect(account.type, PaymentAccountType.other);
    expect(account.name, '');
    expect(account.reference, '');
  });

  test('drops the key type outside Bre-B and the reference of cash', () {
    final content = PaymentAccountMapper.content(
      const PaymentAccount(
        id: 'a',
        name: ' Efectivo ',
        type: PaymentAccountType.cash,
        keyType: BrebKeyType.alias,
        reference: 'x',
      ),
    );
    expect(content, {
      'name': 'Efectivo',
      'type': 'cash',
      'keyType': null,
      'reference': '',
    });
  });

  test('a new account carries timestamps and no deletedAt', () {
    final data = PaymentAccountMapper.create(
      const PaymentAccount(
        id: '',
        name: 'Nequi',
        type: PaymentAccountType.nequi,
        reference: '3001234567',
      ),
    );
    expect(data['createdAt'], isA<FieldValue>());
    expect(data['updatedAt'], isA<FieldValue>());
    expect(data.containsKey('deletedAt'), isTrue);
    expect(data['deletedAt'], isNull);
  });

  test('audit entries use the group log keys', () {
    final entry = PaymentAccountMapper.auditEntry(
      action: 'delete',
      accountId: 'a1',
      uid: 'me',
    );
    expect(entry.keys, {
      'action',
      'entity',
      'entityId',
      'before',
      'after',
      'uid',
      'timestamp',
    });
    expect(entry['entity'], 'paymentAccount');
  });

  test('sortAccounts keeps creation order and undated ones last', () {
    final sorted = sortAccounts([
      const PaymentAccount(
        id: 'pending',
        name: 'c',
        type: PaymentAccountType.other,
        reference: 'abcd',
      ),
      PaymentAccount(
        id: 'b',
        name: 'b',
        type: PaymentAccountType.other,
        reference: 'abcd',
        createdAt: DateTime(2026, 2),
      ),
      PaymentAccount(
        id: 'a',
        name: 'a',
        type: PaymentAccountType.other,
        reference: 'abcd',
        createdAt: DateTime(2026, 1),
      ),
    ]);
    expect(sorted.map((a) => a.id), ['a', 'b', 'pending']);
  });
}
