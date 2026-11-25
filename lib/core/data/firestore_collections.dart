/// Names of the top-level Firestore collections.
abstract final class FirestoreCollections {
  /// `users/{uid}`: profile of each user.
  static const String users = 'users';

  /// `nicknames/{nickname}` → `{uid, email}`: guarantees unique nicknames
  /// and lets users sign in with their nickname.
  static const String nicknames = 'nicknames';
}
