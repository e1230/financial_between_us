import 'package:financial_between_us/features/balances/domain/movement_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debt amount must be positive', () {
    expect(MovementValidators.debtAmount(null), isA<MovementAmountRequired>());
    expect(MovementValidators.debtAmount(0), isA<MovementAmountRequired>());
    expect(MovementValidators.debtAmount(15000), isNull);
    expect(
      MovementValidators.debtAmount(MovementValidators.maxAmount + 1),
      isA<MovementAmountTooHigh>(),
    );
  });

  test('payment amount must not exceed what is pending', () {
    expect(
      MovementValidators.paymentAmount(0, pending: 72000),
      isA<MovementAmountRequired>(),
    );
    expect(MovementValidators.paymentAmount(72000, pending: 72000), isNull);
    final failure = MovementValidators.paymentAmount(72001, pending: 72000);
    expect(failure, isA<MovementAmountTooHigh>());
    expect((failure! as MovementAmountTooHigh).max, 72000);
  });

  test('concept from 1 to 60 characters', () {
    expect(MovementValidators.concept('  '), isA<MovementConceptRequired>());
    expect(MovementValidators.concept('Taxi'), isNull);
    expect(MovementValidators.concept('x' * 60), isNull);
    expect(MovementValidators.concept('x' * 61), isA<MovementConceptTooLong>());
  });

  test('no future dates', () {
    final now = DateTime(2026, 11, 27, 9);
    expect(
      MovementValidators.date(DateTime(2026, 11, 27, 23), now: now),
      isNull,
    );
    expect(MovementValidators.date(DateTime(2026, 11, 1), now: now), isNull);
    expect(
      MovementValidators.date(DateTime(2026, 11, 28), now: now),
      isA<MovementDateInFuture>(),
    );
  });
}
