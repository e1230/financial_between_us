import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_between_us/features/groups/data/group_mapper.dart';
import 'package:financial_between_us/features/groups/data/group_password_hasher.dart';
import 'package:financial_between_us/features/groups/domain/group_member.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a group document', () {
    final created = DateTime.utc(2026, 11, 20);
    final group = GroupMapper.fromFirestore('g1', {
      'name': 'Low IQ Group',
      'code': 'LIQ-7K4P',
      'ownerUid': 'u1',
      'requiresApproval': true,
      'hasPassword': true,
      'members': ['u1', 'u2'],
      'pendingMembers': ['u3'],
      'createdAt': Timestamp.fromDate(created),
      'deletedAt': null,
    });
    expect(group.id, 'g1');
    expect(group.memberCount, 2);
    expect(group.isAdmin('u1'), isTrue);
    // Documents from before `admins`: the owner is the only admin.
    expect(group.adminUids, ['u1']);
    expect(group.isAdmin('u2'), isFalse);
    expect(group.isActiveMember('u2'), isTrue);
    expect(group.isPending('u3'), isTrue);
    expect(group.isPending('u2'), isFalse);
    expect(group.createdAt!.isAtSameMomentAs(created), isTrue);
    expect(group.requiresApproval, isTrue);
  });

  test('reads the admins in promotion order', () {
    final group = GroupMapper.fromFirestore('g1', {
      'ownerUid': 'u1',
      'admins': ['u1', 'u3'],
      'members': ['u1', 'u2', 'u3'],
    });
    expect(group.adminUids, ['u1', 'u3']);
    expect(group.isAdmin('u3'), isTrue);
    expect(group.isOwner('u3'), isFalse);
    expect(group.isAdmin('u2'), isFalse);
  });

  test('missing or malformed fields fall back to defaults', () {
    final group = GroupMapper.fromFirestore('g1', {'members': 'oops'});
    expect(group.name, '');
    expect(group.memberUids, isEmpty);
    expect(group.hasPassword, isFalse);
  });

  test('a new group has its owner as the only active member', () {
    final data = GroupMapper.newGroup(
      name: 'Low IQ Group',
      code: 'LIQ-7K4P',
      ownerUid: 'u1',
      requiresApproval: false,
      hasPassword: false,
    );
    expect(data['members'], ['u1']);
    expect(data['admins'], ['u1']);
    expect(data['pendingMembers'], isEmpty);
    expect(data['createdAt'], isA<FieldValue>());
    expect(data['deletedAt'], isNull);
  });

  test('code entries carry the salt only with a password', () {
    final open = GroupMapper.codeEntry(
      groupId: 'g1',
      name: 'Low IQ Group',
      requiresApproval: false,
      salt: null,
    );
    expect(open['hasPassword'], isFalse);
    final locked = GroupMapper.codeEntry(
      groupId: 'g1',
      name: 'Low IQ Group',
      requiresApproval: true,
      salt: 'abc',
    );
    expect(locked['hasPassword'], isTrue);
    final lookup = GroupMapper.lookupFromFirestore('LIQ-7K4P', {
      ...locked,
      'createdAt': null,
    })!;
    expect(lookup.groupId, 'g1');
    expect(lookup.passwordSalt, 'abc');
    expect(lookup.requiresApproval, isTrue);
    expect(GroupMapper.lookupFromFirestore('X', {'name': 'x'}), isNull);
  });

  test('the code of an archived group finds nothing', () {
    expect(
      GroupMapper.lookupFromFirestore('LIQ-7K4P', {
        'gid': 'g1',
        'name': 'Low IQ Group',
        'deletedAt': Timestamp.fromDate(DateTime.utc(2026, 11, 25)),
      }),
      isNull,
    );
  });

  test('reads member documents', () {
    final joined = DateTime.utc(2026, 11, 20);
    final admin = GroupMapper.memberFromFirestore('u1', {
      'role': 'admin',
      'status': 'active',
      'joinedAt': Timestamp.fromDate(joined),
    });
    expect(admin.role, MemberRole.admin);
    expect(admin.status, MemberStatus.active);
    expect(admin.joinedAt!.isAtSameMomentAs(joined), isTrue);

    final pending = GroupMapper.memberFromFirestore('u2', {
      'role': 'member',
      'status': 'pending',
      'joinedAt': null,
    });
    expect(pending.status, MemberStatus.pending);
    expect(pending.joinedAt, isNull);

    expect(
      GroupMapper.memberFromFirestore('u3', {'status': 'removed'}).status,
      MemberStatus.removed,
    );
    final odd = GroupMapper.memberFromFirestore('u4', {'role': 'x'});
    expect(odd.role, MemberRole.member);
    expect(odd.status, MemberStatus.active);
  });

  test('a removed member is no longer a member', () {
    final data = GroupMapper.removedMember('admin');
    expect(data['status'], 'removed');
    expect(data['role'], 'member');
    expect(data['removedBy'], 'admin');
    expect(data['removedAt'], isA<FieldValue>());
    expect(GroupMapper.isCurrentMember({'status': 'removed'}), isFalse);
  });

  test('members are listed owner, admins, then the rest by join date', () {
    final sorted = sortMembers([
      GroupMember(uid: 'c', joinedAt: DateTime(2026, 3)),
      const GroupMember(uid: 'd'),
      GroupMember(uid: 'b', joinedAt: DateTime(2026, 2)),
      GroupMember(
        uid: 'e',
        role: MemberRole.admin,
        joinedAt: DateTime(2026, 4),
      ),
      GroupMember(uid: 'owner', joinedAt: DateTime(2026, 5)),
    ], 'owner');
    expect(sorted.map((m) => m.uid), ['owner', 'e', 'b', 'c', 'd']);
  });

  test('leaving keeps the member document, marked left', () {
    final data = GroupMapper.leftMember();
    expect(data['status'], 'left');
    expect(data['role'], 'member');
    expect(data['leftAt'], isA<FieldValue>());
    expect(GroupMapper.isCurrentMember(data), isFalse);
    expect(GroupMapper.isCurrentMember({'status': 'active'}), isTrue);
    expect(GroupMapper.isCurrentMember({'status': 'pending'}), isTrue);
    expect(GroupMapper.isCurrentMember(null), isFalse);
  });

  test('password hashes depend on salt and password, never store it', () {
    final hasher = GroupPasswordHasher();
    final salt = hasher.newSalt();
    final hash = hasher.hash(salt: salt, password: 'secreto');
    expect(hash, hasLength(64));
    expect(hash, isNot(contains('secreto')));
    expect(hasher.hash(salt: salt, password: 'secreto'), hash);
    expect(hasher.hash(salt: salt, password: 'otro'), isNot(hash));
    expect(
      hasher.hash(salt: hasher.newSalt(), password: 'secreto'),
      isNot(hash),
    );
  });
}
