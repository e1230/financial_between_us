import 'package:financial_between_us/core/branding/arrow_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArrowFrame.atPhase', () {
    test('starts empty and transparent', () {
      final frame = ArrowFrame.atPhase(0);
      expect(frame.start, 0);
      expect(frame.end, 0);
      expect(frame.opacity, 0);
      expect(frame.headOpacity, 0);
      expect(frame.isStrokeVisible, isFalse);
    });

    test('is fully drawn with its head while holding', () {
      final frame = ArrowFrame.atPhase(0.5);
      expect(frame.start, 0);
      expect(frame.end, 1);
      expect(frame.opacity, 1);
      expect(frame.headOpacity, 1);
    });

    test('erases from the tail after the hold', () {
      final frame = ArrowFrame.atPhase(0.75);
      expect(frame.start, greaterThan(0));
      expect(frame.end, 1);
      expect(frame.opacity, inExclusiveRange(0, 1));
    });

    test('ends empty and transparent', () {
      final frame = ArrowFrame.atPhase(1);
      expect(frame, ArrowFrame.erased);
      expect(frame.opacity, closeTo(0, 1e-9));
      expect(frame.headOpacity, 0);
      expect(frame.isStrokeVisible, isFalse);
    });
  });

  group('ArrowFrame.looping', () {
    test('is hidden before it starts', () {
      expect(ArrowFrame.looping(elapsed: -0.1, period: 1.6), ArrowFrame.hidden);
    });

    test('repeats every period', () {
      expect(
        ArrowFrame.looping(elapsed: 0.8, period: 1.6),
        ArrowFrame.looping(elapsed: 2.4, period: 1.6),
      );
    });
  });
}
