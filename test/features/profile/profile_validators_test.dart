import 'package:financial_between_us/features/profile/domain/profile_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('change password', () {
    test('the current password is required', () {
      expect(
        ProfileValidators.currentPassword(''),
        isA<CurrentPasswordRequired>(),
      );
      expect(ProfileValidators.currentPassword('x'), isNull);
    });

    test('the new password has at least 8 characters', () {
      expect(
        ProfileValidators.newPassword('1234567', current: 'actual'),
        isA<NewPasswordTooShort>(),
      );
      expect(
        ProfileValidators.newPassword('12345678', current: 'actual'),
        isNull,
      );
    });

    test('the new password must differ from the current one', () {
      expect(
        ProfileValidators.newPassword(
          'cuentasclaras',
          current: 'cuentasclaras',
        ),
        isA<SameAsCurrentPassword>(),
      );
    });

    test('the confirmation must match', () {
      expect(
        ProfileValidators.confirmPassword('otra', newPassword: 'nuevaclave'),
        isA<PasswordsDoNotMatch>(),
      );
      expect(
        ProfileValidators.confirmPassword(
          'nuevaclave',
          newPassword: 'nuevaclave',
        ),
        isNull,
      );
    });
  });
}
