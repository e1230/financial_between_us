import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_between_us/features/profile/data/user_profile_mapper.dart';
import 'package:financial_between_us/features/profile/domain/profile_validators.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileMapper.fromFirestore', () {
    test('reads every field', () {
      final created = DateTime.utc(2026, 11, 24, 10);
      final profile = UserProfileMapper.fromFirestore('u1', {
        'displayName': 'Mauricio Beltrán',
        'nickname': 'mao',
        'email': 'mao@correo.com',
        'photoUrl': 'https://res.cloudinary.com/demo/a.jpg',
        'color': '#4FC3F7',
        'profileCompleted': true,
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(created),
        'deletedAt': null,
      });

      expect(
        profile,
        UserProfile(
          uid: 'u1',
          displayName: 'Mauricio Beltrán',
          nickname: 'mao',
          email: 'mao@correo.com',
          photoUrl: 'https://res.cloudinary.com/demo/a.jpg',
          colorValue: 0xFF4FC3F7,
          profileCompleted: true,
          createdAt: created.toLocal(),
          updatedAt: created.toLocal(),
        ),
      );
    });

    test('falls back to defaults for missing or malformed values', () {
      final profile = UserProfileMapper.fromFirestore('u1', {
        'nickname': 'mao',
        'displayName': '  ',
        'color': 'verde',
        // Pending server timestamp: null in the local snapshot.
        'createdAt': null,
      });
      expect(profile.displayName, 'mao');
      expect(profile.colorValue, UserProfile.defaultColorValue);
      expect(profile.profileCompleted, isFalse);
      expect(profile.createdAt, isNull);
      expect(profile.photoUrl, isNull);
    });
  });

  group('UserProfile.initial', () {
    UserProfile profile(String displayName) => UserProfile(
      uid: 'u1',
      displayName: displayName,
      nickname: 'mao',
      email: 'mao@correo.com',
    );

    test('uses the display name, uppercased', () {
      expect(profile('ángela').initial, 'Á');
    });

    test('falls back to the nickname', () {
      expect(profile('').initial, 'M');
    });
  });

  test('display name is optional and up to 40 characters', () {
    expect(ProfileValidators.displayName(''), isNull);
    expect(ProfileValidators.displayName('a' * 40), isNull);
    expect(ProfileValidators.displayName('a' * 41), isA<DisplayNameTooLong>());
  });
}
