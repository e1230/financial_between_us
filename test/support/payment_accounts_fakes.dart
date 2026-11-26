import 'dart:async';

import 'package:financial_between_us/core/platform/share_service.dart';
import 'package:financial_between_us/features/payment_accounts/data/payment_accounts_repository.dart';
import 'package:financial_between_us/features/payment_accounts/domain/payment_account.dart';
import 'package:financial_between_us/features/payment_accounts/domain/payment_account_failure.dart';

/// The four accounts of the reference screenshots.
List<PaymentAccount> sampleAccounts() => [
  PaymentAccount(
    id: 'a1',
    name: 'Nequi personal',
    type: PaymentAccountType.nequi,
    reference: '3001234567',
    createdAt: DateTime(2026, 1, 1),
  ),
  PaymentAccount(
    id: 'a2',
    name: 'Llave Bre-B',
    type: PaymentAccountType.breb,
    keyType: BrebKeyType.alias,
    reference: '@mao1230',
    createdAt: DateTime(2026, 1, 2),
  ),
  PaymentAccount(
    id: 'a3',
    name: 'Daviplata',
    type: PaymentAccountType.daviplata,
    reference: '3109876543',
    createdAt: DateTime(2026, 1, 3),
  ),
  PaymentAccount(
    id: 'a4',
    name: 'Efectivo',
    type: PaymentAccountType.cash,
    reference: '',
    createdAt: DateTime(2026, 1, 4),
  ),
];

/// Payment accounts in memory, for one user.
class FakePaymentAccountsRepository implements PaymentAccountsRepository {
  FakePaymentAccountsRepository({List<PaymentAccount>? accounts})
    : accounts = [...?accounts];

  final List<PaymentAccount> accounts;

  /// Thrown by the next write.
  PaymentAccountFailure? failure;

  final List<String> calls = [];
  final _changes = StreamController<void>.broadcast();
  var _nextId = 100;

  List<PaymentAccount> get _live => sortAccounts([
    for (final a in accounts)
      if (a.deletedAt == null) a,
  ]);

  void _throwIfNeeded() {
    final pending = failure;
    if (pending != null) {
      failure = null;
      throw pending;
    }
  }

  @override
  Stream<List<PaymentAccount>> watch(String uid) async* {
    yield _live;
    yield* _changes.stream.map((_) => _live);
  }

  @override
  Future<String> create({
    required String uid,
    required PaymentAccount account,
  }) async {
    calls.add('create:${account.name}');
    _throwIfNeeded();
    final id = 'new${_nextId++}';
    accounts.add(account.copyWith(id: id, createdAt: DateTime(2026, 6)));
    _changes.add(null);
    return id;
  }

  @override
  Future<void> update({
    required String uid,
    required PaymentAccount account,
  }) async {
    calls.add('update:${account.id}');
    _throwIfNeeded();
    final i = accounts.indexWhere((a) => a.id == account.id);
    if (i < 0) throw const PaymentAccountNotFound();
    accounts[i] = account;
    _changes.add(null);
  }

  @override
  Future<void> delete({
    required String uid,
    required PaymentAccount account,
  }) async {
    calls.add('delete:${account.id}');
    _throwIfNeeded();
    final i = accounts.indexWhere((a) => a.id == account.id);
    accounts[i] = accounts[i].copyWith(deletedAt: DateTime(2026, 6));
    _changes.add(null);
  }
}

/// Records what was shared instead of opening the system sheet.
class FakeShareService implements ShareService {
  final List<String> shared = [];

  @override
  Future<void> shareText(String text) async => shared.add(text);
}
