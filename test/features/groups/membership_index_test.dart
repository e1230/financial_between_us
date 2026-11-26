import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/membership_index.dart';
import 'package:flutter_test/flutter_test.dart';

Group _group(
  String id, {
  List<String> members = const [],
  List<String> pending = const [],
  DateTime? deletedAt,
}) => Group(
  id: id,
  name: id,
  code: 'AAA-2222',
  ownerUid: 'owner',
  memberUids: members,
  pendingUids: pending,
  deletedAt: deletedAt,
);

void main() {
  test('adds active groups missing from the index', () {
    final diff = diffMembershipIndex(
      uid: 'me',
      groups: [
        _group('g1', members: ['me']),
        _group('g2', members: ['me']),
      ],
      indexed: ['g1'],
    );
    expect(diff.toAdd, ['g2']);
    expect(diff.toRemove, isEmpty);
  });

  test('pending requests and archived groups are not indexed', () {
    final diff = diffMembershipIndex(
      uid: 'me',
      groups: [
        _group('pending', pending: ['me']),
        _group('archived', members: ['me'], deletedAt: DateTime(2026)),
      ],
      indexed: ['archived'],
    );
    expect(diff.toAdd, isEmpty);
    expect(diff.toRemove, ['archived']);
  });

  test('removes groups the user is no longer in', () {
    final diff = diffMembershipIndex(
      uid: 'me',
      groups: const [],
      indexed: ['gone'],
    );
    expect(diff.toRemove, ['gone']);
  });

  test('nothing to do when in sync', () {
    expect(
      diffMembershipIndex(
        uid: 'me',
        groups: [
          _group('g1', members: ['me']),
        ],
        indexed: ['g1'],
      ).isEmpty,
      isTrue,
    );
  });
}
