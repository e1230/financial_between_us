import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/firestore_collections.dart';
import '../domain/user_profile.dart';
import 'user_profile_mapper.dart';

/// The nickname was reserved by someone else.
class NicknameTakenException implements Exception {
  const NicknameTakenException();
}

/// Reads and writes `users/{uid}` (and reserves `nicknames/{nickname}`).
abstract interface class UserProfileRepository {
  /// Reserves [nickname] and creates `users/{uid}` in one transaction, with
  /// `profileCompleted: false`.
  ///
  /// Throws [NicknameTakenException] if the nickname is already reserved.
  Future<void> createWithNickname({
    required String uid,
    required String nickname,
    required String email,
    required String displayName,
  });

  /// The profile, or `null` if `users/{uid}` does not exist.
  Future<UserProfile?> fetch(String uid);

  /// Live profile; `null` while `users/{uid}` does not exist.
  Stream<UserProfile?> watch(String uid);

  /// Saves the optional data of "Completa tu perfil" and marks the profile
  /// as completed.
  // DECISIÓN: profile changes are not written to `auditLog`: that log lives
  // under `groups/{groupId}` and is about the group's money, not about who a
  // user is.
  Future<void> completeProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int colorValue,
  });

  /// Saves the editable data of the profile: name, photo and color.
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int colorValue,
  });
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection(FirestoreCollections.users).doc(uid);

  DocumentReference<Map<String, dynamic>> _nickname(String nickname) =>
      _firestore.collection(FirestoreCollections.nicknames).doc(nickname);

  @override
  Future<void> createWithNickname({
    required String uid,
    required String nickname,
    required String email,
    required String displayName,
  }) {
    final nicknameRef = _nickname(nickname);
    return _firestore.runTransaction((transaction) async {
      final reserved = await transaction.get(nicknameRef);
      if (reserved.exists) throw const NicknameTakenException();
      transaction
        ..set(nicknameRef, {'uid': uid, 'email': email})
        ..set(
          _user(uid),
          UserProfileMapper.newUser(
            nickname: nickname,
            email: email,
            displayName: displayName,
          ),
        );
    });
  }

  @override
  Future<UserProfile?> fetch(String uid) async {
    final snapshot = await _user(uid).get();
    final data = snapshot.data();
    return data == null ? null : UserProfileMapper.fromFirestore(uid, data);
  }

  @override
  Stream<UserProfile?> watch(String uid) => _user(uid).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : UserProfileMapper.fromFirestore(uid, data);
  });

  @override
  Future<void> completeProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int colorValue,
  }) => _user(uid).update(
    UserProfileMapper.completion(
      displayName: displayName,
      photoUrl: photoUrl,
      colorValue: colorValue,
    ),
  );

  @override
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String? photoUrl,
    required int colorValue,
  }) => _user(uid).update(
    UserProfileMapper.update(
      displayName: displayName,
      photoUrl: photoUrl,
      colorValue: colorValue,
    ),
  );
}
