import '../../domain/payment_account_failure.dart';
import '../payment_accounts_strings.dart';

/// Message shown for an error of a payment account request.
String accountFailureMessage(Object error) => switch (error) {
  PaymentAccountNetworkFailure() => PaymentAccountsStrings.networkError,
  PaymentAccountNotFound() => PaymentAccountsStrings.notFound,
  _ => PaymentAccountsStrings.genericError,
};
