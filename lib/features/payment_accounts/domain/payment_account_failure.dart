/// Why a payment account request failed. The presentation layer maps each
/// case to its message.
sealed class PaymentAccountFailure implements Exception {
  const PaymentAccountFailure();
}

/// No connection (or the server took too long).
final class PaymentAccountNetworkFailure extends PaymentAccountFailure {
  const PaymentAccountNetworkFailure();
}

/// The account no longer exists or was deleted.
final class PaymentAccountNotFound extends PaymentAccountFailure {
  const PaymentAccountNotFound();
}

/// Anything else, with the Firebase error [code] when there is one.
final class UnknownPaymentAccountFailure extends PaymentAccountFailure {
  const UnknownPaymentAccountFailure([this.code]);

  final String? code;
}
