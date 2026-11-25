import 'group_code.dart';

/// Why a field of the group forms is invalid. The presentation layer maps
/// each failure to its message.
sealed class GroupFieldFailure {
  const GroupFieldFailure();
}

/// The field is empty.
final class GroupFieldRequired extends GroupFieldFailure {
  const GroupFieldRequired();
}

/// The group name is shorter than [GroupValidators.minNameLength].
final class GroupNameTooShort extends GroupFieldFailure {
  const GroupNameTooShort();
}

/// The group name is longer than [GroupValidators.maxNameLength].
final class GroupNameTooLong extends GroupFieldFailure {
  const GroupNameTooLong();
}

/// The password is shorter than [GroupValidators.minPasswordLength].
final class GroupPasswordTooShort extends GroupFieldFailure {
  const GroupPasswordTooShort();
}

/// The join code is not like `LIQ-7K4P`.
final class GroupCodeMalformed extends GroupFieldFailure {
  const GroupCodeMalformed();
}

/// Client-side validation of the group forms. `null` means valid.
abstract final class GroupValidators {
  static const int minNameLength = 3;
  static const int maxNameLength = 40;
  static const int minPasswordLength = 4;
  static const int maxPasswordLength = 64;

  static GroupFieldFailure? name(String value) {
    final name = value.trim();
    if (name.isEmpty) return const GroupFieldRequired();
    if (name.length < minNameLength) return const GroupNameTooShort();
    if (name.length > maxNameLength) return const GroupNameTooLong();
    return null;
  }

  /// Optional when creating a group: empty means no password.
  static GroupFieldFailure? optionalPassword(String value) {
    if (value.isEmpty) return null;
    return value.length < minPasswordLength
        ? const GroupPasswordTooShort()
        : null;
  }

  /// Required when joining a group that has one.
  static GroupFieldFailure? password(String value) =>
      value.isEmpty ? const GroupFieldRequired() : null;

  /// [code] must be normalized first (`GroupCode.normalize`).
  static GroupFieldFailure? code(String code) {
    if (code.isEmpty) return const GroupFieldRequired();
    return GroupCode.isValid(code) ? null : const GroupCodeMalformed();
  }
}
