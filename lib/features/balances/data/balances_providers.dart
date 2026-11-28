import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/cloudinary_providers.dart';
import '../../../core/data/firestore_providers.dart';
import '../../auth/data/auth_providers.dart';
import '../../groups/data/groups_providers.dart';
import '../../groups/domain/group.dart';
import '../../notifications/data/notifications_data_providers.dart';
import '../../notifications/data/notifying_movements_repository.dart';
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

/// The ledger; every write also notifies the other party.
@Riverpod(keepAlive: true)
MovementsRepository movementsRepository(Ref ref) =>
    NotifyingMovementsRepository(
      FirestoreMovementsRepository(ref.watch(firebaseFirestoreProvider)),
      ref.watch(notificationDispatcherProvider),
    );

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

/// The movement [movementId] of [groupId], read once: the one a
/// notification opens. `null` when it does not exist.
@riverpod
Future<LedgerMovement?> movementById(
  Ref ref,
  String groupId,
  String movementId,
) => ref
    .watch(movementsRepositoryProvider)
    .fetchMovement(groupId: groupId, movementId: movementId);

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

/// How many movements "Últimos movimientos" reads: a few more than it shows,
/// since rejected and deleted ones are skipped.
const int recentReadLimit = 10;

/// Live newest movements of [groupId] where the user is a party, read with
/// a limit instead of the whole group.
@Riverpod(retry: _noRetry)
Stream<List<LedgerMovement>> recentGroupMovements(
  Ref ref,
  String groupId,
) async* {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* ref
      .watch(movementsRepositoryProvider)
      .watchRecent(groupId: groupId, me: user.uid, limit: recentReadLimit);
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

/// Movements per page of a history.
const int historyPageSize = 20;

/// The loaded part of the history of a person.
final class PairHistoryState {
  const PairHistoryState({
    required this.items,
    required this.hasMore,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  static const PairHistoryState empty = PairHistoryState(
    items: [],
    hasMore: false,
  );

  /// Loaded movements without the deleted ones, newest first.
  final List<LedgerMovement> items;

  /// There may be older movements to load.
  final bool hasMore;
  final bool loadingMore;

  /// The last [PairHistory.loadMore] failed (offer "Reintentar").
  final bool loadMoreFailed;
}

/// The history of the signed-in user with [otherUid] in [scope], loaded a
/// page at a time ([historyPageSize] movements) so the server only sends
/// what the user scrolls to. The newest page stays live (new, rejected and
/// deleted movements show up at once); older pages are read once.
@Riverpod(retry: _noRetry)
class PairHistory extends _$PairHistory {
  MovementPage _live = MovementPage.empty;

  /// Movements older than the live page: loaded pages plus the ones a new
  /// movement pushed out of it.
  final Map<String, LedgerMovement> _older = {};
  Object? _olderCursor;
  bool _olderHasMore = true;
  bool _loadingMore = false;
  bool _loadMoreFailed = false;
  String _me = '';

  MovementsRepository get _repository => ref.read(movementsRepositoryProvider);

  @override
  Stream<PairHistoryState> build(BalancesScope scope, String otherUid) async* {
    _live = MovementPage.empty;
    _older.clear();
    _olderCursor = null;
    _olderHasMore = true;
    _loadingMore = false;
    _loadMoreFailed = false;
    final user = await ref.watch(authStateChangesProvider.future);
    if (user == null) {
      yield PairHistoryState.empty;
      return;
    }
    _me = user.uid;
    final pages = ref
        .watch(movementsRepositoryProvider)
        .watchPairHistory(
          me: _me,
          other: otherUid,
          groupId: scope.groupId,
          limit: historyPageSize,
        );
    await for (final page in pages) {
      final ids = {for (final m in page.items) m.id};
      for (final m in _live.items) {
        if (!ids.contains(m.id)) _older[m.id] = m;
      }
      for (final id in ids) {
        _older.remove(id);
      }
      _live = page;
      yield _compose();
    }
  }

  PairHistoryState _compose() {
    final items = [
      for (final m in [..._live.items, ..._older.values])
        if (!m.isDeleted) m,
    ]..sort((a, b) => compareChronologically(b, a));
    return PairHistoryState(
      items: items,
      hasMore: _olderCursor == null ? _live.hasMore : _olderHasMore,
      loadingMore: _loadingMore,
      loadMoreFailed: _loadMoreFailed,
    );
  }

  /// Loads the next older page, if there is one and none is loading.
  Future<void> loadMore() async {
    if (_loadingMore || !state.hasValue || !state.requireValue.hasMore) return;
    final cursor = _olderCursor ?? _live.cursor;
    if (cursor == null) return;
    _loadingMore = true;
    _loadMoreFailed = false;
    state = AsyncData(_compose());
    try {
      final page = await _repository.fetchPairHistory(
        me: _me,
        other: otherUid,
        groupId: scope.groupId,
        limit: historyPageSize,
        after: cursor,
      );
      final live = {for (final m in _live.items) m.id};
      for (final m in page.items) {
        if (!live.contains(m.id)) _older[m.id] = m;
      }
      _olderCursor = page.cursor ?? cursor;
      _olderHasMore = page.hasMore;
    } catch (_) {
      _loadMoreFailed = true;
    } finally {
      _loadingMore = false;
      if (ref.mounted) state = AsyncData(_compose());
    }
  }

  /// Applies [change] to the loaded movement [id] of an older page (the
  /// live page updates by itself), e.g. after rejecting or deleting it.
  void patch(String id, LedgerMovement Function(LedgerMovement) change) {
    final m = _older[id];
    if (m == null) return;
    _older[id] = change(m);
    state = AsyncData(_compose());
  }
}
