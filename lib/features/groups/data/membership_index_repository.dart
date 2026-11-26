import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/firestore_collections.dart';

/// Field of `userGroups/{uid}`.
abstract final class MembershipIndexFields {
  /// Groups where the user is an active member.
  static const String groupIds = 'groupIds';
}

/// `userGroups/{uid}`: the groups where a user is an active member. The
/// security rules use it to let people who share a group read each other's
/// payment accounts (rules cannot search the groups themselves).
///
/// The group flows keep it up to date in their own batches (see
/// `FirestoreGroupsRepository`); this repository repairs the signed-in
/// user's own entry (e.g. for groups joined before the index existed).
abstract interface class MembershipIndexRepository {
  /// Indexed group ids of [uid] (empty if the document does not exist).
  Future<List<String>> read(String uid);

  /// Adds [groupId] to the index of [uid].
  Future<void> add({required String uid, required String groupId});

  /// Removes [groupId] from the index of [uid].
  Future<void> remove({required String uid, required String groupId});
}

class FirestoreMembershipIndexRepository implements MembershipIndexRepository {
  FirestoreMembershipIndexRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      MembershipIndex.ref(_firestore, uid);

  @override
  Future<List<String>> read(String uid) async {
    final data = (await _doc(uid).get()).data();
    final ids = data?[MembershipIndexFields.groupIds];
    return ids is List ? ids.whereType<String>().toList() : const [];
  }

  @override
  Future<void> add({required String uid, required String groupId}) =>
      _doc(uid).set(MembershipIndex.added(groupId), MembershipIndex.merge);

  @override
  Future<void> remove({required String uid, required String groupId}) =>
      _doc(uid).set(MembershipIndex.removed(groupId), MembershipIndex.merge);
}

/// Writes of `userGroups/{uid}`, shared with the group batches. The rules
/// accept exactly one group added or removed per write.
abstract final class MembershipIndex {
  static DocumentReference<Map<String, dynamic>> ref(
    FirebaseFirestore firestore,
    String uid,
  ) => firestore.collection(FirestoreCollections.userGroups).doc(uid);

  /// Merge data that adds [groupId].
  static Map<String, Object?> added(String groupId) => {
    MembershipIndexFields.groupIds: FieldValue.arrayUnion([groupId]),
  };

  /// Merge data that removes [groupId].
  static Map<String, Object?> removed(String groupId) => {
    MembershipIndexFields.groupIds: FieldValue.arrayRemove([groupId]),
  };

  /// Options of every index write (creates the document if needed).
  static final SetOptions merge = SetOptions(merge: true);
}
