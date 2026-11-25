import 'package:financial_between_us/features/groups/domain/group_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('name: required, 3 to 40 characters after trimming', () {
    expect(GroupValidators.name('   '), isA<GroupFieldRequired>());
    expect(GroupValidators.name(' ab '), isA<GroupNameTooShort>());
    expect(GroupValidators.name('abc'), isNull);
    expect(GroupValidators.name('a' * 40), isNull);
    expect(GroupValidators.name('a' * 41), isA<GroupNameTooLong>());
  });

  test('optional password: empty or at least 4 characters', () {
    expect(GroupValidators.optionalPassword(''), isNull);
    expect(
      GroupValidators.optionalPassword('abc'),
      isA<GroupPasswordTooShort>(),
    );
    expect(GroupValidators.optionalPassword('abcd'), isNull);
  });

  test('joining password is required', () {
    expect(GroupValidators.password(''), isA<GroupFieldRequired>());
    expect(GroupValidators.password('x'), isNull);
  });

  test('code must be normalized and well formed', () {
    expect(GroupValidators.code(''), isA<GroupFieldRequired>());
    expect(GroupValidators.code('LIQ7K4P'), isA<GroupCodeMalformed>());
    expect(GroupValidators.code('LIQ-7K4P'), isNull);
  });
}
