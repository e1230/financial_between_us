import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/balances/data/balances_providers.dart';
import 'package:financial_between_us/features/balances/domain/balances_scope.dart';
import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';
import '../../support/ledger_builders.dart';
import '../../support/movements_fakes.dart';

/// [count] debts of Santi with the user, one per hour, `d0` the oldest.
List<LedgerMovement> _debts(int count, {String groupId = 'g1'}) => [
  for (var i = 0; i < count; i++)
    debtOf(
      'd$i',
      'santi',
      'me',
      1000,
      groupId: groupId,
    ).copyWith(date: DateTime(2026, 11, 1).add(Duration(hours: i))),
];

void main() {
  late FakeMovementsRepository repo;
  late ProviderContainer container;
  const scope = BalancesScope.group('g1');
  final provider = pairHistoryProvider(scope, 'santi');

  ProviderContainer start(List<LedgerMovement> movements) {
    repo = FakeMovementsRepository(movements);
    container = ProviderContainer(
      overrides: [
        authStateChangesProvider.overrideWith(
          (ref) => Stream.value(FakeUser(uid: 'me')),
        ),
        movementsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.listen(provider, (_, _) {});
    return container;
  }

  Future<PairHistoryState> settle() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    return container.read(provider).requireValue;
  }

  test('loads the newest page first and older pages on demand', () async {
    start(_debts(45));
    var state = await settle();
    expect(state.items, hasLength(historyPageSize));
    expect(state.items.first.id, 'd44');
    expect(state.hasMore, isTrue);
    expect(repo.fetchedPages, 0);

    await container.read(provider.notifier).loadMore();
    state = await settle();
    expect(state.items, hasLength(40));
    expect(state.hasMore, isTrue);

    await container.read(provider.notifier).loadMore();
    state = await settle();
    expect(state.items, hasLength(45));
    expect(state.items.last.id, 'd0');
    expect(state.hasMore, isFalse);
    expect(repo.fetchedPages, 2);

    // Nothing more to ask for.
    await container.read(provider.notifier).loadMore();
    expect(repo.fetchedPages, 2);
  });

  test(
    'a new movement does not drop the one it pushes out of the live page',
    () async {
      start(_debts(25));
      await settle();
      await repo.registerDebt(
        debtOf('nueva', 'santi', 'me', 500).copyWith(date: DateTime(2026, 12)),
      );
      final state = await settle();
      expect(state.items, hasLength(21));
      expect(state.items.first.amount, 500);
      expect(state.items.map((m) => m.id), contains('d5'));
    },
  );

  test('deleted movements are hidden and older pages can be patched', () async {
    start([
      ..._debts(30),
      debtOf(
        'gone',
        'santi',
        'me',
        1000,
        status: MovementStatus.deleted,
      ).copyWith(date: DateTime(2026, 12)),
    ]);
    await settle();
    await container.read(provider.notifier).loadMore();
    var state = await settle();
    expect(state.items.map((m) => m.id), isNot(contains('gone')));
    expect(state.items, hasLength(30));

    container
        .read(provider.notifier)
        .patch('d0', (m) => m.copyWith(status: MovementStatus.rejected));
    state = await settle();
    expect(state.items.firstWhere((m) => m.id == 'd0').isRejected, isTrue);
  });

  test('"Todos los grupos" reads the pair in every group', () async {
    repo = FakeMovementsRepository([
      ..._debts(3),
      ..._debts(2, groupId: 'g2').map((m) => m.copyWith(id: 'x${m.id}')),
    ]);
    container = ProviderContainer(
      overrides: [
        authStateChangesProvider.overrideWith(
          (ref) => Stream.value(FakeUser(uid: 'me')),
        ),
        movementsRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final all = pairHistoryProvider(const BalancesScope.all(), 'santi');
    container.listen(all, (_, _) {});
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(all).requireValue.items, hasLength(5));
  });

  test('balances only read active movements', () async {
    final repo = FakeMovementsRepository([
      debtOf('a', 'santi', 'me', 1000),
      debtOf('b', 'santi', 'me', 1000, status: MovementStatus.rejected),
    ]);
    expect((await repo.watchGroup('g1').first).map((m) => m.id), ['a']);
  });
}
