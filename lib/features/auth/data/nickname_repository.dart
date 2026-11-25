import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/firestore_collections.dart';
import '../../../core/data/firestore_providers.dart';

part 'nickname_repository.g.dart';

/// Read side of `nicknames/{nickname}` (reservations are written together
/// with the profile, see `UserProfileRepository.createWithNickname`).
abstract interface class NicknameRepository {
  /// Whether nobody reserved [nickname] yet.
  Future<bool> isAvailable(String nickname);

  /// Email of the account that owns [nickname], or `null`.
  Future<String?> emailFor(String nickname);
}

class FirestoreNicknameRepository implements NicknameRepository {
  FirestoreNicknameRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> _read(String nickname) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.nicknames)
        .doc(nickname)
        .get();
    return snapshot.data();
  }

  @override
  Future<bool> isAvailable(String nickname) async =>
      await _read(nickname) == null;

  @override
  Future<String?> emailFor(String nickname) async =>
      (await _read(nickname))?['email'] as String?;
}

@Riverpod(keepAlive: true)
NicknameRepository nicknameRepository(Ref ref) =>
    FirestoreNicknameRepository(ref.watch(firebaseFirestoreProvider));
