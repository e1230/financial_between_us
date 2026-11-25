/// Letters derived from a group name: the mosaic initials and the letters
/// of the join code prefix.
abstract final class GroupInitials {
  /// Short Spanish words that do not count for the mosaic initials.
  static const Set<String> stopWords = {
    'a', 'al', 'con', 'de', 'del', 'e', 'el', 'en', 'la', 'las', 'los', //
    'o', 'para', 'por', 'u', 'y',
  };

  static const Map<String, String> _accents = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'Ü': 'U',
    'Ñ': 'N',
  };

  /// Two uppercase letters for the mosaic: the first letter of the first
  /// and of the last significant word ("Viaje a Villa de Leyva" → "VL").
  /// A single word gives its first two letters; no letters give "?".
  // DECISIÓN: first and last significant word; the handoff only shows
  // examples, not the rule.
  static String of(String name) {
    final words = _words(name);
    if (words.isEmpty) return '?';
    final significant = words
        .where((w) => !stopWords.contains(w.toLowerCase()))
        .toList();
    final list = significant.isEmpty ? words : significant;
    final result = list.length == 1
        ? list.single.substring(0, list.single.length < 2 ? 1 : 2)
        : '${list.first[0]}${list.last[0]}';
    return result.toUpperCase();
  }

  /// Uppercase letters for the code prefix: the initial of each word, or
  /// every letter of an acronym ("Low IQ Group" → L, I, Q, G).
  static List<String> codeLetters(String name) => [
    for (final word in _words(name))
      if (word.length > 1 && word == word.toUpperCase())
        ...word.split('')
      else
        word[0].toUpperCase(),
  ];

  /// Words of [name] made only of A–Z letters (accents removed, case kept).
  static List<String> _words(String name) => name
      .split('')
      .map((c) => _accents[c] ?? c)
      .join()
      .split(RegExp('[^A-Za-z]+'))
      .where((w) => w.isNotEmpty)
      .toList();
}
