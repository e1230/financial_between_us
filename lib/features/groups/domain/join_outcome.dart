/// Result of joining a group with its code.
sealed class JoinOutcome {
  const JoinOutcome();
}

/// The user is now an active member of [groupId].
final class Joined extends JoinOutcome {
  const Joined(this.groupId);

  final String groupId;
}

/// The group requires approval: the membership is pending.
final class PendingApproval extends JoinOutcome {
  const PendingApproval(this.groupName);

  final String groupName;
}
