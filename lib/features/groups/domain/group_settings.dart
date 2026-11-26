import 'group.dart';
import 'group_validators.dart';

/// What happens to the group password when its settings are saved.
sealed class PasswordChange {
  const PasswordChange();
}

/// The password (or its absence) stays as it is.
final class KeepPassword extends PasswordChange {
  const KeepPassword();
}

/// A new password: asked from now on, the old one stops working.
final class SetPassword extends PasswordChange {
  const SetPassword(this.password);

  final String password;
}

/// No password from now on.
final class RemovePassword extends PasswordChange {
  const RemovePassword();
}

/// Settings an admin edits: name, approval of new members and password.
final class GroupSettings {
  const GroupSettings({
    required this.name,
    required this.requiresApproval,
    this.password = const KeepPassword(),
  });

  final String name;
  final bool requiresApproval;
  final PasswordChange password;

  /// Whether the group has a password once these settings apply.
  bool hasPasswordFor(Group group) => switch (password) {
    KeepPassword() => group.hasPassword,
    SetPassword() => true,
    RemovePassword() => false,
  };

  /// Whether saving these settings would change [group].
  bool changes(Group group) =>
      name.trim() != group.name ||
      requiresApproval != group.requiresApproval ||
      switch (password) {
        KeepPassword() => false,
        SetPassword() => true,
        RemovePassword() => group.hasPassword,
      };

  /// The settings an admin chose in the edit form. With [askPassword] on,
  /// an empty [newPassword] keeps the current password if there is one.
  factory GroupSettings.fromForm({
    required Group group,
    required String name,
    required bool requiresApproval,
    required bool askPassword,
    required String newPassword,
  }) => GroupSettings(
    name: name.trim(),
    requiresApproval: requiresApproval,
    password: !askPassword
        ? (group.hasPassword ? const RemovePassword() : const KeepPassword())
        : newPassword.isEmpty
        ? const KeepPassword()
        : SetPassword(newPassword),
  );

  /// Validation of the password field of the edit form: required only
  /// when the group asks for a password and does not have one yet.
  static GroupFieldFailure? passwordError({
    required Group group,
    required bool askPassword,
    required String newPassword,
  }) {
    if (!askPassword) return null;
    if (newPassword.isEmpty && !group.hasPassword) {
      return const GroupFieldRequired();
    }
    return GroupValidators.optionalPassword(newPassword);
  }
}
