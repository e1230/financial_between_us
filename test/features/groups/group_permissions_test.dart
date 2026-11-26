import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:flutter_test/flutter_test.dart';

/// "owner" is the main admin, "ana" another admin and "beto" and "carla"
/// plain members; "dani" is pending.
const _group = Group(
  id: 'g1',
  name: 'Fútbol',
  code: 'FUT-2345',
  ownerUid: 'owner',
  adminUids: ['owner', 'ana'],
  memberUids: ['owner', 'ana', 'beto', 'carla'],
  pendingUids: ['dani'],
);

void main() {
  test('the owner and the promoted members are admins', () {
    expect(_group.isOwner('owner'), isTrue);
    expect(_group.isOwner('ana'), isFalse);
    expect(_group.isAdmin('owner'), isTrue);
    expect(_group.isAdmin('ana'), isTrue);
    expect(_group.isAdmin('beto'), isFalse);
  });

  test('any admin promotes active members who are not admins yet', () {
    expect(_group.canPromote('owner', 'beto'), isTrue);
    expect(_group.canPromote('ana', 'beto'), isTrue);
    expect(_group.canPromote('beto', 'carla'), isFalse);
    expect(_group.canPromote('owner', 'ana'), isFalse);
    expect(_group.canPromote('owner', 'dani'), isFalse);
  });

  test('only the owner demotes, and never themselves', () {
    expect(_group.canDemote('owner', 'ana'), isTrue);
    expect(_group.canDemote('ana', 'owner'), isFalse);
    expect(_group.canDemote('owner', 'owner'), isFalse);
    expect(_group.canDemote('owner', 'beto'), isFalse);
  });

  test('admins remove plain members; only the owner removes admins', () {
    expect(_group.canRemove('ana', 'beto'), isTrue);
    expect(_group.canRemove('owner', 'ana'), isTrue);
    expect(_group.canRemove('ana', 'owner'), isFalse);
    expect(_group.canRemove('ana', 'ana'), isFalse);
    expect(_group.canRemove('beto', 'carla'), isFalse);
    expect(_group.canRemove('owner', 'dani'), isFalse);

    const twoAdmins = Group(
      id: 'g2',
      name: 'Asado',
      code: 'ASA-2345',
      ownerUid: 'owner',
      adminUids: ['owner', 'ana', 'beto'],
      memberUids: ['owner', 'ana', 'beto'],
    );
    expect(twoAdmins.canRemove('ana', 'beto'), isFalse);
  });
}
