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

  /// `groups/{groupId}/movements/{movementId}`: debts and payments between
  /// members, the ledger every balance is computed from.
  static const String groupMovements = 'movements';

  /// `groups/{groupId}/auditLog/{logId}`: write-only change log.
  static const String groupAuditLog = 'auditLog';

  /// `users/{uid}/paymentAccounts/{accountId}`: where the user receives
  /// payments. Readable by the owner and by whoever shares a group with
  /// them.
  static const String paymentAccounts = 'paymentAccounts';

  /// `users/{uid}/auditLog/{logId}`: write-only log of the user's own
  /// changes (payment accounts).
  static const String userAuditLog = 'auditLog';

  /// `userGroups/{uid}` → `{groupIds}`: groups where the user is an active
  /// member. Lets the security rules tell whether two users share a group.
  static const String userGroups = 'userGroups';
}
