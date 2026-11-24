import 'package:financial_between_us/features/auth/domain/auth_validators.dart';
import 'package:financial_between_us/features/auth/domain/mask_email.dart';
import 'package:financial_between_us/features/auth/presentation/auth_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('username', () {
    test('is required', () {
      expect(AuthValidators.username('  '), const FieldRequired());
    });

    test('accepts 3 to 20 lowercase letters, digits, dot or underscore', () {
      expect(AuthValidators.username('juanes_92'), isNull);
      expect(AuthValidators.username('a.b'), isNull);
      expect(AuthValidators.username('a' * 20), isNull);
    });

    test('rejects other characters and lengths', () {
      for (final value in ['ab', 'a' * 21, 'Juanes', 'juan es', 'juan-es']) {
        expect(
          AuthValidators.username(value),
          const UsernameInvalid(),
          reason: value,
        );
      }
    });
  });

  group('email', () {
    test('is required', () {
      expect(AuthValidators.email(''), const FieldRequired());
    });

    test('accepts a well-formed address', () {
      expect(AuthValidators.email(' nombre@correo.com '), isNull);
    });

    test('rejects malformed addresses', () {
      for (final value in [
        'nombre',
        'nombre@',
        '@correo.com',
        'a@b',
        'a b@c.co',
      ]) {
        expect(
          AuthValidators.email(value),
          const EmailInvalid(),
          reason: value,
        );
      }
    });
  });

  group('new password', () {
    test('needs at least 8 characters and reports the missing count', () {
      expect(AuthValidators.newPassword(''), const PasswordTooShort(8));
      expect(AuthValidators.newPassword('abcde'), const PasswordTooShort(3));
      expect(AuthValidators.newPassword('abcdefgh'), isNull);
    });
  });

  group('messages', () {
    test('required messages depend on the field', () {
      const required = FieldRequired();
      expect(
        AuthStrings.fieldFailure(required, AuthField.username),
        'Escribe un nombre de usuario.',
      );
      expect(
        AuthStrings.fieldFailure(required, AuthField.email),
        'Escribe tu correo.',
      );
      expect(
        AuthStrings.fieldFailure(required, AuthField.loginIdentifier),
        'Escribe tu usuario o tu correo.',
      );
      expect(
        AuthStrings.fieldFailure(required, AuthField.loginPassword),
        'Escribe tu contraseña.',
      );
    });

    test('short password says how many characters are missing', () {
      expect(
        AuthStrings.fieldFailure(const PasswordTooShort(3), AuthField.password),
        'Le faltan 3 caracteres: mínimo 8.',
      );
      expect(
        AuthStrings.fieldFailure(const PasswordTooShort(1), AuthField.password),
        'Le falta 1 carácter: mínimo 8.',
      );
    });

    test('resend countdown is formatted as m:ss', () {
      expect(
        AuthStrings.resendIn(const Duration(seconds: 45)),
        'Reenviar en 0:45',
      );
      expect(
        AuthStrings.resendIn(const Duration(seconds: 5)),
        'Reenviar en 0:05',
      );
    });
  });

  group('maskEmail', () {
    test('keeps the first letter and the domain', () {
      expect(maskEmail('juan@correo.com'), 'j•••@correo.com');
      expect(maskEmail(' j@correo.com '), 'j•••@correo.com');
    });

    test('masks everything when there is no local part or domain', () {
      expect(maskEmail(''), '•••');
      expect(maskEmail('@correo.com'), '•••');
      expect(maskEmail('juan@'), '•••');
    });
  });
}
