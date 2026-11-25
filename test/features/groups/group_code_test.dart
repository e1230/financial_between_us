import 'dart:math';

import 'package:financial_between_us/features/groups/domain/group_code.dart';
import 'package:financial_between_us/features/groups/domain/group_initials.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('prefixFor', () {
    test('takes word initials and every letter of acronyms', () {
      expect(GroupCode.prefixFor('Low IQ Group'), 'LIQ');
      expect(GroupCode.prefixFor('Fútbol de los jueves'), 'FDL');
      expect(GroupCode.prefixFor('Viaje a Villa de Leyva'), 'VAV');
    });

    test('pads short names with X and ignores symbols and digits', () {
      expect(GroupCode.prefixFor('Yo'), 'YXX');
      expect(GroupCode.prefixFor('Ñoños 2025!'), 'NXX');
      expect(GroupCode.prefixFor('123'), 'XXX');
    });
  });

  test('generate builds a valid code from the safe alphabet', () {
    final random = Random(7);
    for (var i = 0; i < 200; i++) {
      final code = GroupCode.generate('Low IQ Group', random);
      expect(GroupCode.isValid(code), isTrue, reason: code);
      expect(code.startsWith('LIQ-'), isTrue);
      expect(code.substring(4), isNot(matches(RegExp('[01IO]'))));
    }
  });

  group('normalize', () {
    test('uppercases, drops spaces and puts the hyphen in position 4', () {
      expect(GroupCode.normalize('liq7k4p'), 'LIQ-7K4P');
      expect(GroupCode.normalize(' liq - 7k4p '), 'LIQ-7K4P');
      expect(GroupCode.normalize('LIQ-7K4P'), 'LIQ-7K4P');
      expect(GroupCode.normalize('li'), 'LI');
    });

    test('keeps extra characters so validation rejects them', () {
      final code = GroupCode.normalize('LIQ7K4PX');
      expect(code, 'LIQ-7K4PX');
      expect(GroupCode.isValid(code), isFalse);
    });
  });

  test('isValid rejects confusable characters in the random part', () {
    expect(GroupCode.isValid('LIQ-7K4P'), isTrue);
    expect(GroupCode.isValid('LIQ-0K4P'), isFalse);
    expect(GroupCode.isValid('LIQ-IK4P'), isFalse);
    expect(GroupCode.isValid('LI1-7K4P'), isFalse);
  });

  group('GroupInitials.of', () {
    test('first and last significant words', () {
      expect(GroupInitials.of('Fútbol de los jueves'), 'FJ');
      expect(GroupInitials.of('Viaje a Villa de Leyva'), 'VL');
      expect(GroupInitials.of('Low IQ Group'), 'LG');
    });

    test('a single word gives its first two letters', () {
      expect(GroupInitials.of('amigos'), 'AM');
      expect(GroupInitials.of('Y'), 'Y');
      expect(GroupInitials.of('!!'), '?');
    });
  });
}
