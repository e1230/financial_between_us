import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_between_us/features/groups/data/group_mapper.dart';
import 'package:financial_between_us/features/groups/data/group_password_hasher.dart';
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
    expect(group.isActiveMember('u2'), isTrue);
    expect(group.isPending('u3'), isTrue);
    expect(group.isPending('u2'), isFalse);
    expect(group.createdAt!.isAtSameMomentAs(created), isTrue);
    expect(group.requiresApproval, isTrue);
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
