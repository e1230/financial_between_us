/// Why a field of the payment or debt forms is invalid. The presentation
/// layer maps each failure to its message.
sealed class MovementFieldFailure {
  const MovementFieldFailure();
}

/// The amount is missing or zero ("Escribe un monto.").
final class MovementAmountRequired extends MovementFieldFailure {
  const MovementAmountRequired();
}

/// A payment bigger than what is pending.
final class MovementAmountTooHigh extends MovementFieldFailure {
  const MovementAmountTooHigh(this.max);

  /// Whole pesos pending.
  final int max;
}

/// The debt concept is empty.
final class MovementConceptRequired extends MovementFieldFailure {
  const MovementConceptRequired();
}

/// The debt concept is longer than [MovementValidators.maxConceptLength].
final class MovementConceptTooLong extends MovementFieldFailure {
  const MovementConceptTooLong();
}

/// The date is in the future.
final class MovementDateInFuture extends MovementFieldFailure {
  const MovementDateInFuture();
}

/// Client-side validation of the payment and debt forms. `null` means
/// valid. The security rules check the amount again.
abstract final class MovementValidators {
  static const int maxConceptLength = 60;

  /// "Otro motivo" of a rejection.
  static const int maxRejectNoteLength = 80;

  /// Upper bound of any amount, so a typo cannot create an absurd debt.
  // DECISIÓN: $ 100.000.000 is far above any outing of a group of friends.
  static const int maxAmount = 100000000;

  /// An amount of a debt: more than zero.
  static MovementFieldFailure? debtAmount(int? amount) {
    if (amount == null || amount <= 0) return const MovementAmountRequired();
    if (amount > maxAmount) return const MovementAmountTooHigh(maxAmount);
    return null;
  }

  /// An amount of a payment: more than zero and at most [pending].
  static MovementFieldFailure? paymentAmount(
    int? amount, {
    required int pending,
  }) {
    if (amount == null || amount <= 0) return const MovementAmountRequired();
    if (amount > pending) return MovementAmountTooHigh(pending);
    return null;
  }

  static MovementFieldFailure? concept(String value) {
    final concept = value.trim();
    if (concept.isEmpty) return const MovementConceptRequired();
    if (concept.length > maxConceptLength) {
      return const MovementConceptTooLong();
    }
    return null;
  }

  /// The day [date] must not be after the day of [now].
  static MovementFieldFailure? date(DateTime date, {required DateTime now}) {
    final day = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return day.isAfter(today) ? const MovementDateInFuture() : null;
  }
}
