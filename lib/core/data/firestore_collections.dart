/// Names of the Firestore collections, so no widget or repository hardcodes
/// them.
abstract final class FirestoreCollections {
  /// `users/{uid}`: profile of each user.
  static const String users = 'users';

  /// `nicknames/{nickname}` → `{uid, email}`: guarantees unique nicknames
  /// and lets users sign in with their nickname.
  static const String nicknames = 'nicknames';

  /// `groups/{groupId}`: groups of friends.
  static const String groups = 'groups';

  /// `groupCodes/{code}` → `{gid, name, hasPassword, requiresApproval,
  /// salt}`: unique join codes, readable by anyone who knows the code.
  static const String groupCodes = 'groupCodes';

  /// `groups/{groupId}/members/{uid}`: role and status of each member.
  static const String groupMembers = 'members';

  /// `groups/{groupId}/secrets/{doc}`: never readable by the app.
  static const String groupSecrets = 'secrets';

  /// `groups/{groupId}/secrets/password` → `{hash}`.
  static const String groupPasswordDoc = 'password';

  /// `groups/{groupId}/joinProofs/{uid}` → `{hash}`: the password hash a
  /// user sent to join; the security rules compare it with the secret.
  static const String groupJoinProofs = 'joinProofs';

  /// `groups/{groupId}/auditLog/{logId}`: write-only change log.
  static const String groupAuditLog = 'auditLog';
}
