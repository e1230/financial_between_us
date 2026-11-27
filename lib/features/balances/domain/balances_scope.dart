/// Tabs of the balances screen.
enum BalancesTab {
  /// The group shown in the Home.
  group,

  /// Every group of the user.
  all,
}

/// Which groups a balance covers: one group or all the user's groups.
final class BalancesScope {
  /// Only [groupId].
  const BalancesScope.group(String this.groupId);

  /// Every group where the user is an active member.
  const BalancesScope.all() : groupId = null;

  /// The group, or `null` for all of them.
  final String? groupId;

  bool get isAll => groupId == null;

  /// Value of the `group` query parameter of the person route.
  static const String allParam = 'all';

  /// The scope of a `group` query parameter (see [param]).
  static BalancesScope fromParam(String? value) =>
      value == null || value.isEmpty || value == allParam
      ? const BalancesScope.all()
      : BalancesScope.group(value);

  /// The group id, or [allParam].
  String get param => groupId ?? allParam;

  @override
  bool operator ==(Object other) =>
      other is BalancesScope && other.groupId == groupId;

  @override
  int get hashCode => groupId.hashCode;

  @override
  String toString() => 'BalancesScope(${groupId ?? 'all'})';
}
