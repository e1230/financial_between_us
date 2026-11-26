import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/groups/domain/group_settings.dart';
import 'package:financial_between_us/features/groups/domain/group_validators.dart';
import 'package:flutter_test/flutter_test.dart';

const _open = Group(id: 'g1', name: 'Fútbol', code: 'FUT-2345', ownerUid: 'a');
const _locked = Group(
  id: 'g1',
  name: 'Fútbol',
  code: 'FUT-2345',
  ownerUid: 'a',
  hasPassword: true,
  requiresApproval: true,
);

GroupSettings _form(
  Group group, {
  String? name,
  bool? requiresApproval,
  bool? askPassword,
  String newPassword = '',
}) => GroupSettings.fromForm(
  group: group,
  name: name ?? group.name,
  requiresApproval: requiresApproval ?? group.requiresApproval,
  askPassword: askPassword ?? group.hasPassword,
  newPassword: newPassword,
);

void main() {
  test('the untouched form changes nothing', () {
    expect(_form(_open).changes(_open), isFalse);
    expect(_form(_locked).changes(_locked), isFalse);
    // Spaces around the name do not count.
    expect(_form(_open, name: ' Fútbol ').changes(_open), isFalse);
  });

  test('name and approval changes are detected', () {
    expect(_form(_open, name: 'Asado').changes(_open), isTrue);
    expect(_form(_open, requiresApproval: true).changes(_open), isTrue);
  });

  test('an empty password field keeps the current password', () {
    final settings = _form(_locked);
    expect(settings.password, isA<KeepPassword>());
    expect(settings.hasPasswordFor(_locked), isTrue);
  });

  test('a new password replaces the old one or adds one', () {
    final change = _form(_locked, newPassword: 'nueva');
    expect((change.password as SetPassword).password, 'nueva');
    expect(change.changes(_locked), isTrue);

    final add = _form(_open, askPassword: true, newPassword: 'clave');
    expect(add.hasPasswordFor(_open), isTrue);
    expect(add.changes(_open), isTrue);
  });

  test('turning the password off removes it', () {
    final settings = _form(_locked, askPassword: false, newPassword: 'x');
    expect(settings.password, isA<RemovePassword>());
    expect(settings.hasPasswordFor(_locked), isFalse);
    expect(settings.changes(_locked), isTrue);
    expect(_form(_open, askPassword: false).password, isA<KeepPassword>());
  });

  test('the password is required only when the group has none yet', () {
    GroupFieldFailure? error(Group group, bool ask, String value) =>
        GroupSettings.passwordError(
          group: group,
          askPassword: ask,
          newPassword: value,
        );
    expect(error(_open, true, ''), isA<GroupFieldRequired>());
    expect(error(_open, true, 'abc'), isA<GroupPasswordTooShort>());
    expect(error(_open, true, 'abcd'), isNull);
    expect(error(_open, false, ''), isNull);
    expect(error(_locked, true, ''), isNull);
    expect(error(_locked, true, 'ab'), isA<GroupPasswordTooShort>());
  });
}
