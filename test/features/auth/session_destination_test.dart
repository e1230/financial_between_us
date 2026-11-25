import 'package:financial_between_us/features/auth/domain/session_destination.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = UserProfile(
    uid: 'u1',
    displayName: 'mao',
    nickname: 'mao',
    email: 'mao@correo.com',
  );

  test('without users/{uid} the user chooses a nickname', () {
    expect(sessionDestinationFor(null), SessionDestination.chooseNickname);
  });

  test('an unfinished profile goes to complete it', () {
    expect(sessionDestinationFor(profile), SessionDestination.completeProfile);
  });

  test('a completed profile goes home', () {
    expect(
      sessionDestinationFor(profile.copyWith(profileCompleted: true)),
      SessionDestination.home,
    );
  });
}
