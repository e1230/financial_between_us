/// Why a group request failed. The presentation layer maps each case to its
/// message.
sealed class GroupFailure implements Exception {
  const GroupFailure();
}

/// No group has that join code.
final class GroupCodeNotFound extends GroupFailure {
  const GroupCodeNotFound();
}

/// The user is already a member (active or pending) of the group.
final class AlreadyMember extends GroupFailure {
  const AlreadyMember();
}

/// The user is no longer a member of the group (already left, or it was
/// archived).
final class NotAMember extends GroupFailure {
  const NotAMember();
}

/// Only the admin of the group can do that.
final class NotGroupAdmin extends GroupFailure {
  const NotGroupAdmin();
}

/// The group password does not match.
final class WrongGroupPassword extends GroupFailure {
  const WrongGroupPassword();
}

/// Every generated join code was taken (very unlikely).
final class CodeGenerationExhausted extends GroupFailure {
  const CodeGenerationExhausted();
}

/// No connection.
final class GroupNetworkFailure extends GroupFailure {
  const GroupNetworkFailure();
}

/// Anything else (e.g. rejected by the security rules).
final class UnknownGroupFailure extends GroupFailure {
  const UnknownGroupFailure([this.code]);

  /// Technical code, only for logs.
  final String? code;
}
