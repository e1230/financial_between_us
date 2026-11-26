import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/group_failure.dart';
import 'package:financial_between_us/features/groups/domain/leave_plan.dart';
import 'package:flutter_test/flutter_test.dart';

Group _group({
  String owner = 'owner',
  List<String> members = const ['owner', 'ana', 'beto'],
  List<String> pending = const [],
  DateTime? deletedAt,
}) => Group(
  id: 'g1',
  name: 'Fútbol',
  code: 'FUT-2345',
  ownerUid: owner,
  memberUids: members,
  pendingUids: pending,
  deletedAt: deletedAt,
);

void main() {
  test('a member who is not the owner just leaves', () {
    expect(planLeave(_group(), 'ana'), isA<LeaveAsMember>());
  });

  test('the owner hands the group to the oldest remaining member', () {
    final plan = planLeave(_group(members: ['beto', 'owner', 'ana']), 'owner');
    expect(plan, isA<LeaveAndTransfer>());
    expect((plan as LeaveAndTransfer).newOwnerUid, 'beto');

    final next = planLeave(_group(), 'owner') as LeaveAndTransfer;
    expect(next.newOwnerUid, 'ana');
  });

  test('pending members do not inherit the group', () {
    final plan = planLeave(
      _group(members: ['owner'], pending: ['ana']),
      'owner',
    );
    expect(plan, isA<LeaveAndArchive>());
  });

  test('the owner alone archives the group', () {
    expect(
      planLeave(_group(members: ['owner']), 'owner'),
      isA<LeaveAndArchive>(),
    );
  });

  test('a pending member cancels the request', () {
    expect(
      planLeave(_group(pending: ['carla']), 'carla'),
      isA<CancelRequest>(),
    );
  });

  test('someone outside the group, or an archived group, cannot leave', () {
    expect(() => planLeave(_group(), 'stranger'), throwsA(isA<NotAMember>()));
    expect(
      () => planLeave(_group(deletedAt: DateTime(2026, 11, 25)), 'ana'),
      throwsA(isA<NotAMember>()),
    );
  });
}
