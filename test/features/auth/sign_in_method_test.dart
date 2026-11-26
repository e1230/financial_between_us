import 'package:financial_between_us/features/auth/domain/sign_in_method.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an email account signs in with a password', () {
    expect(signInMethodFor(['password']), SignInMethod.password);
  });

  test('a Google account signs in with Google', () {
    expect(signInMethodFor(['google.com']), SignInMethod.google);
  });

  test('an account with both can still change its password', () {
    expect(signInMethodFor(['google.com', 'password']), SignInMethod.password);
  });

  test('unknown providers give no method', () {
    expect(signInMethodFor([]), isNull);
    expect(signInMethodFor(['phone']), isNull);
  });
}
