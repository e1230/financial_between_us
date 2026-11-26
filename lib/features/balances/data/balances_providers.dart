import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_providers.dart';
import '../../groups/data/groups_providers.dart';
import '../domain/debt.dart';
import '../domain/pair_balances.dart';
import 'balances_repository.dart';

part 'balances_providers.g.dart';

@Riverpod(keepAlive: true)
BalancesRepository balancesRepository(Ref ref) =>
    const FakeBalancesRepository();

/// Live debts of [groupId]; empty when the user is not in the group.
@riverpod
Stream<List<Debt>> groupDebts(Ref ref, String groupId) async* {
  final group = await ref.watch(groupByIdProvider(groupId).future);
  if (group == null) {
    yield const [];
    return;
  }
  yield* ref.watch(balancesRepositoryProvider).watchDebts(group);
}

/// Balance of the signed-in user with each member of [groupId] (see
/// [balancesWith]): positive "Te debe", negative "Debes", absent "a mano".
@riverpod
Future<Map<String, int>> myBalances(Ref ref, String groupId) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const {};
  final debts = await ref.watch(groupDebtsProvider(groupId).future);
  return balancesWith(user.uid, debts);
}
