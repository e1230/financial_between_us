import 'dart:math';

import 'group_initials.dart';

/// Join codes of the groups, like `LIQ-7K4P`: three letters from the group
/// name, a hyphen and four characters without the confusable 0, O, 1 and I.
abstract final class GroupCode {
  /// Characters of the random part.
  static const String alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static const int prefixLength = 3;
  static const int suffixLength = 4;
  static const String separator = '-';

  /// Filler of the prefix when the name has fewer than three letters.
  static const String filler = 'X';

  /// Length of a full code, hyphen included.
  static const int length = prefixLength + 1 + suffixLength;

  /// A well-formed code (also enforced by the Firestore rules).
  static final RegExp pattern = RegExp(r'^[A-Z]{3}-[A-HJ-NP-Z2-9]{4}$');

  /// The prefix of [groupName]: its first three code letters, padded with
  /// [filler] ("Low IQ Group" → `LIQ`, "Yo" → `YXX`).
  static String prefixFor(String groupName) =>
      GroupInitials.codeLetters(groupName)
          .take(prefixLength)
          .join()
          .padRight(prefixLength, filler);

  /// A new random code for [groupName].
  static String generate(String groupName, Random random) {
    final suffix = List.generate(
      suffixLength,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    return '${prefixFor(groupName)}$separator$suffix';
  }

  /// Cleans what the user typed: uppercase, no spaces or hyphens, and the
  /// hyphen back in the fourth position (`liq 7k4p` → `LIQ-7K4P`). Extra
  /// characters are kept so validation can reject them.
  static String normalize(String input) {
    final raw = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (raw.length <= prefixLength) return raw;
    return '${raw.substring(0, prefixLength)}$separator'
        '${raw.substring(prefixLength)}';
  }

  /// Whether [code] (already normalized) is well formed.
  static bool isValid(String code) => pattern.hasMatch(code);
}
