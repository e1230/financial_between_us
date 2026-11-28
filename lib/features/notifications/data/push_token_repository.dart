import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/firestore_collections.dart';

/// Field names of `users/{uid}/fcmTokens/{token}`.
abstract final class FcmTokenFields {
  static const String token = 'token';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';

  /// Set when the user signs out on that device, or by the Worker when FCM
  /// says the token no longer exists. Never deleted.
  static const String deletedAt = 'deletedAt';
}

/// Where each user receives push notifications.
abstract interface class PushTokenRepository {
  /// [token] receives the notifications of [uid] (again, if it was retired).
  Future<void> save({required String uid, required String token});

  /// [token] stops receiving them (soft delete).
  Future<void> retire({required String uid, required String token});
}

class FirestorePushTokenRepository implements PushTokenRepository {
  FirestorePushTokenRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String token) =>
      _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.fcmTokens)
          .doc(token);

  @override
  Future<void> save({required String uid, required String token}) async {
    final ref = _doc(uid, token);
    await _firestore.runTransaction((tx) async {
      final now = FieldValue.serverTimestamp();
      if ((await tx.get(ref)).exists) {
        tx.update(ref, {
          FcmTokenFields.updatedAt: now,
          FcmTokenFields.deletedAt: null,
        });
      } else {
        tx.set(ref, {
          FcmTokenFields.token: token,
          FcmTokenFields.createdAt: now,
          FcmTokenFields.updatedAt: now,
          FcmTokenFields.deletedAt: null,
        });
      }
    });
  }

  @override
  Future<void> retire({required String uid, required String token}) async {
    final now = FieldValue.serverTimestamp();
    await _doc(
      uid,
      token,
    ).update({FcmTokenFields.updatedAt: now, FcmTokenFields.deletedAt: now});
  }
}
