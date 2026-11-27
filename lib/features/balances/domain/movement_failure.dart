/// Why a movement request failed. The presentation layer maps each case to
/// its message.
sealed class MovementFailure implements Exception {
  const MovementFailure();
}

/// No connection (or the server took too long).
final class MovementNetworkFailure extends MovementFailure {
  const MovementNetworkFailure();
}

/// The attached image could not be uploaded; nothing was saved.
final class MovementAttachmentFailure extends MovementFailure {
  const MovementAttachmentFailure();
}

/// The attached image is heavier than `ReceiptPicker.maxBytes` even after
/// resizing it.
final class MovementAttachmentTooLarge extends MovementFailure {
  const MovementAttachmentTooLarge();
}

/// The movement is no longer active (someone rejected or deleted it
/// first), or the user may not do that.
final class MovementNotAllowed extends MovementFailure {
  const MovementNotAllowed();
}

/// Anything else, with the Firebase error [code] when there is one.
final class UnknownMovementFailure extends MovementFailure {
  const UnknownMovementFailure([this.code]);

  final String? code;
}
