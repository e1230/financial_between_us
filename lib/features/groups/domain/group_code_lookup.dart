/// What anyone with a join code can see of the group
/// (`groupCodes/{code}`), before being a member.
class GroupCodeLookup {
  const GroupCodeLookup({
    required this.code,
    required this.groupId,
    required this.groupName,
    required this.hasPassword,
    required this.requiresApproval,
    this.passwordSalt,
  });

  final String code;
  final String groupId;
  final String groupName;
  final bool hasPassword;
  final bool requiresApproval;

  /// Salt of the group password hash; only when [hasPassword].
  final String? passwordSalt;
}

/// The group a user just created.
class CreatedGroup {
  const CreatedGroup({
    required this.groupId,
    required this.name,
    required this.code,
    required this.hasPassword,
  });

  final String groupId;
  final String name;
  final String code;
  final bool hasPassword;
}
