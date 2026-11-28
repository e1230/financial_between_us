import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/balances/domain/movement_failure.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/group_code_lookup.dart';
import 'package:financial_between_us/features/groups/domain/group_failure.dart';
import 'package:financial_between_us/features/notifications/data/notifying_groups_repository.dart';
import 'package:financial_between_us/features/notifications/data/notifying_movements_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/group_fakes.dart';
import '../../support/movements_fakes.dart';
import '../../support/notification_fakes.dart';

LedgerMovement _payment(String groupId) => LedgerMovement(
  id: '',
  groupId: groupId,
  type: LedgerMovementType.payment,
  debtorUid: sampleMe,
  creditorUid: 'santi',
  amount: 20000,
  date: DateTime(2026, 11, 27),
  createdBy: sampleMe,
);

void main() {
  group('movements', () {
    late FakeMovementsRepository inner;
    late FakeNotificationDispatcher dispatcher;
    late NotifyingMovementsRepository repo;

    setUp(() {
      inner = FakeMovementsRepository();
      dispatcher = FakeNotificationDispatcher();
      repo = NotifyingMovementsRepository(inner, dispatcher);
    });

    test('payments in several groups notify once per group', () async {
      final ids = await repo.registerPayments([
        _payment('g1'),
        _payment('g2'),
        _payment('g1'),
      ]);
      expect(dispatcher.bodies, [
        {
          'type': 'movement.created',
          'groupId': 'g1',
          'movementIds': [ids[0], ids[2]],
        },
        {
          'type': 'movement.created',
          'groupId': 'g2',
          'movementIds': [ids[1]],
        },
      ]);
    });

    test('a debt, a rejection and a deletion notify', () async {
      final debt = _payment('g1').copyWith(
        type: LedgerMovementType.debt,
        kind: DebtKind.direct,
        concept: 'Pizza',
      );
      final id = await repo.registerDebt(debt);
      final saved = inner.movementsOf('g1').single;
      expect(saved.id, id);

      final theirs = saved.copyWith(id: 'm2', createdBy: 'santi');
      final other = FakeMovementsRepository([theirs]);
      final notifying = NotifyingMovementsRepository(other, dispatcher);
      await notifying.reject(
        movement: theirs,
        uid: sampleMe,
        reason: RejectReason.wrongAmount,
      );
      await repo.delete(movement: saved, uid: sampleMe);

      expect(dispatcher.bodies, [
        {
          'type': 'movement.created',
          'groupId': 'g1',
          'movementIds': [id],
        },
        {
          'type': 'movement.rejected',
          'groupId': 'g1',
          'movementIds': ['m2'],
        },
        {
          'type': 'movement.deleted',
          'groupId': 'g1',
          'movementIds': [id],
        },
      ]);
    });

    test('a failed write notifies nobody', () async {
      inner.writeError = const MovementNetworkFailure();
      await expectLater(
        repo.registerDebt(_payment('g1')),
        throwsA(isA<MovementNetworkFailure>()),
      );
      expect(dispatcher.events, isEmpty);
    });

    test('marking as seen notifies nobody', () async {
      final mine = _payment('g1').copyWith(id: 'm1', createdBy: 'santi');
      final notifying = NotifyingMovementsRepository(
        FakeMovementsRepository([mine]),
        dispatcher,
      );
      await notifying.markSeen(movement: mine, uid: sampleMe);
      expect(dispatcher.events, isEmpty);
    });
  });

  group('groups', () {
    Group group({bool approval = false}) => Group(
      id: 'g1',
      name: 'Viernes',
      code: 'VIE-2345',
      ownerUid: 'ana',
      memberUids: const ['ana', 'beto'],
      pendingUids: const ['dani'],
      requiresApproval: approval,
      createdAt: DateTime(2026),
    );

    GroupCodeLookup lookup({bool approval = false}) => GroupCodeLookup(
      code: 'VIE-2345',
      groupId: 'g1',
      groupName: 'Viernes',
      hasPassword: false,
      requiresApproval: approval,
    );

    test('joining notifies a join or a request', () async {
      final dispatcher = FakeNotificationDispatcher();
      final repo = NotifyingGroupsRepository(
        FakeGroupsRepository(groups: [group()]),
        dispatcher,
      );
      await repo.join(group: lookup(), uid: 'caro');
      await repo.join(group: lookup(approval: true), uid: 'eli');
      expect(dispatcher.bodies, [
        {'type': 'member.joined', 'groupId': 'g1'},
        {'type': 'member.requested', 'groupId': 'g1'},
      ]);
    });

    test('leaving, approving and removing notify', () async {
      final dispatcher = FakeNotificationDispatcher();
      final repo = NotifyingGroupsRepository(
        FakeGroupsRepository(groups: [group()]),
        dispatcher,
      );
      await repo.approveMember(
        groupId: 'g1',
        adminUid: 'ana',
        memberUid: 'dani',
      );
      await repo.removeMember(
        groupId: 'g1',
        adminUid: 'ana',
        memberUid: 'beto',
      );
      await repo.leave(groupId: 'g1', uid: 'dani');
      expect(dispatcher.bodies, [
        {'type': 'member.approved', 'groupId': 'g1', 'memberUid': 'dani'},
        {'type': 'member.removed', 'groupId': 'g1', 'memberUid': 'beto'},
        {'type': 'member.left', 'groupId': 'g1'},
      ]);
    });

    test('rejecting a request and other admin changes notify nobody', () async {
      final dispatcher = FakeNotificationDispatcher();
      final repo = NotifyingGroupsRepository(
        FakeGroupsRepository(groups: [group()]),
        dispatcher,
      );
      await repo.rejectMember(
        groupId: 'g1',
        adminUid: 'ana',
        memberUid: 'dani',
      );
      await repo.promoteMember(
        groupId: 'g1',
        adminUid: 'ana',
        memberUid: 'beto',
      );
      expect(dispatcher.events, isEmpty);
    });

    test('a failed change notifies nobody', () async {
      final dispatcher = FakeNotificationDispatcher();
      final inner = FakeGroupsRepository(groups: [group()])
        ..failure = const NotAMember();
      final repo = NotifyingGroupsRepository(inner, dispatcher);
      await expectLater(
        repo.leave(groupId: 'g1', uid: 'beto'),
        throwsA(isA<NotAMember>()),
      );
      expect(dispatcher.events, isEmpty);
    });
  });
}
