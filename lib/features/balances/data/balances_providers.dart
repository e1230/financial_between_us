import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/cloudinary_providers.dart';
import '../../../core/data/firestore_providers.dart';
import '../../auth/data/auth_providers.dart';
import '../../groups/data/groups_providers.dart';
import '../../groups/domain/group.dart';
import '../domain/balances_overview.dart';
import '../domain/balances_scope.dart';
import '../domain/debt.dart';
import '../domain/group_event.dart';
import '../domain/ledger_movement.dart';
import '../domain/pair_balances.dart';
import '../domain/pair_ledger.dart';
import '../domain/person_ledger.dart';
import 'group_events_repository.dart';
import 'movement_actions.dart';
import 'movements_repository.dart';
import 'receipt_picker.dart';
import 'receipt_uploader.dart';

part 'balances_providers.g.dart';

@Riverpod(keepAlive: true)
MovementsRepository movementsRepository(Ref ref) =>
    FirestoreMovementsRepository(ref.watch(firebaseFirestoreProvider));

@Riverpod(keepAlive: true)
ReceiptUploader receiptUploader(Ref ref) =>
    CloudinaryReceiptUploader(ref.watch(cloudinaryImageUploaderProvider));

@Riverpod(keepAlive: true)
ReceiptPicker receiptPicker(Ref ref) => DeviceReceiptPicker();

@Riverpod(keepAlive: true)
GroupEventsRepository groupEventsRepository(Ref ref) =>
    const NoGroupEventsRepository();

@Riverpod(keepAlive: true)
MovementActions movementActions(Ref ref) => MovementActions(
  repository: ref.watch(movementsRepositoryProvider),
  uploader: ref.watch(receiptUploaderProvider),
);

/// Events of [groupId] a debt can belong to, newest first.
@riverpod
Stream<List<GroupEvent>> groupEvents(Ref ref, String groupId) =>
    ref.watch(groupEventsRepositoryProvider).watch(groupId);

/// Live movements of [groupId]; empty when the user is not in the group.
///
/// Not retried on error: Firestore already reconnects by itself, a denied
/// read does not fix itself, and the screens offer "Reintentar".
@Riverpod(retry: _noRetry)
Stream<List<LedgerMovement>> groupMovements(Ref ref, String groupId) async* {
  final group = await ref.watch(groupByIdProvider(groupId).future);
  if (group == null) {
    yield const [];
    return;
  }
  yield* ref.watch(movementsRepositoryProvider).watchGroup(groupId);
}

/// What is still owed between the people of [groupId] (see
/// [debtsFromMovements]).
@riverpod
Future<List<Debt>> groupDebts(Ref ref, String groupId) async =>
    debtsFromMovements(await ref.watch(groupMovementsProvider(groupId).future));

/// Balance of the signed-in user with each member of [groupId] (see
/// [balancesWith]): positive "Te debe", negative "Debes", absent "a mano".
@riverpod
Future<Map<String, int>> myBalances(Ref ref, String groupId) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const {};
  final debts = await ref.watch(groupDebtsProvider(groupId).future);
  return balancesWith(user.uid, debts);
}

/// Tab of the balances screen; kept while the app is open.
@Riverpod(keepAlive: true)
class SelectedBalancesTab extends _$SelectedBalancesTab {
  @override
  BalancesTab build() => BalancesTab.group;

  void select(BalancesTab tab) => state = tab;
}

/// Groups of [scope] where the user is an active member: the group (if it
/// still is one of theirs) or all of them.
@riverpod
Future<List<Group>> scopeGroups(Ref ref, BalancesScope scope) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return const [];
  final groups = await ref.watch(myGroupsProvider.future);
  return [
    for (final g in groups)
      if (g.isActiveMember(user.uid) && (scope.isAll || g.id == scope.groupId))
        g,
  ];
}

/// Movements and members of each group of [scope].
@Riverpod(retry: _noRetry)
Future<List<GroupLedgerInput>> scopeLedgerInputs(
  Ref ref,
  BalancesScope scope,
) async {
  final groups = await ref.watch(scopeGroupsProvider(scope).future);
  final movements = await Future.wait([
    for (final g in groups) ref.watch(groupMovementsProvider(g.id).future),
  ]);
  return [
    for (var i = 0; i < groups.length; i++)
      GroupLedgerInput(
        groupId: groups[i].id,
        memberUids: groups[i].memberUids,
        movements: movements[i],
      ),
  ];
}

/// The balances screen of [scope].
@Riverpod(retry: _noRetry)
Future<BalancesOverview> balancesOverview(Ref ref, BalancesScope scope) async {
  final user = await ref.watch(authStateChangesProvider.future);
  final inputs = await ref.watch(scopeLedgerInputsProvider(scope).future);
  return BalancesOverview.compute(me: user?.uid ?? '', groups: inputs);
}

/// The signed-in user's ledger with [otherUid] across the groups of
/// [scope].
@Riverpod(retry: _noRetry)
Future<PersonLedger> personLedger(
  Ref ref,
  BalancesScope scope,
  String otherUid,
) async {
  final user = await ref.watch(authStateChangesProvider.future);
  final me = user?.uid ?? '';
  final inputs = await ref.watch(scopeLedgerInputsProvider(scope).future);
  final perGroup = <String, PairLedger>{};
  for (final input in inputs) {
    final ledger = PairLedger.compute(
      me: me,
      other: otherUid,
      movements: input.movements,
    );
    if (input.memberUids.contains(otherUid) || ledger.history.isNotEmpty) {
      perGroup[input.groupId] = ledger;
    }
  }
  return PersonLedger(
    ledger: PairLedger.merge(me: me, other: otherUid, ledgers: perGroup.values),
    groupIds: perGroup.keys.toList(),
  );
}

Duration? _noRetry(int retryCount, Object error) => null;
