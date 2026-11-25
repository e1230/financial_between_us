import 'package:financial_between_us/features/groups/domain/active_group.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:flutter_test/flutter_test.dart';

Group _group(
  String id, {
  List<String> members = const ['me'],
  List<String> pending = const [],
  DateTime? created,
}) => Group(
  id: id,
  name: id,
  code: 'AAA-2222',
  ownerUid: 'owner',
  memberUids: members,
  pendingUids: pending,
  createdAt: created,
);

void main() {
  final a = _group('a', created: DateTime(2026, 1));
  final b = _group('b', created: DateTime(2026, 2));
  final pending = _group('p', members: const ['x'], pending: const ['me']);

  test('uses the saved group while the user is an active member', () {
    expect(resolveActiveGroup(groups: [a, b], selectedId: 'b', uid: 'me'), b);
  });

  test('falls back to the first active group', () {
    expect(
      resolveActiveGroup(groups: [a, b], selectedId: 'gone', uid: 'me'),
      a,
    );
    expect(resolveActiveGroup(groups: [a, b], selectedId: null, uid: 'me'), a);
  });

  test('a pending group is never active', () {
    expect(
      resolveActiveGroup(groups: [pending], selectedId: 'p', uid: 'me'),
      isNull,
    );
    expect(
      resolveActiveGroup(groups: [pending, b], selectedId: 'p', uid: 'me'),
      b,
    );
    expect(
      resolveActiveGroup(groups: const [], selectedId: null, uid: 'me'),
      isNull,
    );
  });

  test('selector order: active by date (unsaved last), then pending', () {
    final unsaved = _group('new');
    expect(sortGroupsFor('me', [pending, unsaved, b, a]).map((g) => g.id), [
      'a',
      'b',
      'new',
      'p',
    ]);
  });
}
