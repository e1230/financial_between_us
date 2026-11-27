import '../../domain/movement_failure.dart';
import '../balances_strings.dart';

/// Message of an error of a movement request.
String movementFailureMessage(Object error) => switch (error) {
  MovementNetworkFailure() => BalancesStrings.networkError,
  MovementAttachmentFailure() => BalancesStrings.uploadFailed,
  MovementAttachmentTooLarge() => BalancesStrings.imageTooLarge,
  MovementNotAllowed() => BalancesStrings.notAllowed,
  _ => BalancesStrings.unknownError,
};
