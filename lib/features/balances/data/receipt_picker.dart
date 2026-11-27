import 'package:image_picker/image_picker.dart';

import '../domain/movement_failure.dart';

/// Where the attached image comes from.
enum ReceiptSource { camera, gallery }

/// An image chosen to attach to a movement, still on the device.
final class PickedReceipt {
  const PickedReceipt({
    required this.path,
    required this.name,
    required this.bytes,
  });

  final String path;

  /// File name, shown in the form.
  final String name;
  final int bytes;
}

/// Lets the user take or choose the image of a movement.
abstract interface class ReceiptPicker {
  /// The resized image, or `null` if the user cancelled. Throws
  /// [MovementAttachmentTooLarge] when it is still heavier than [maxBytes].
  Future<PickedReceipt?> pick(ReceiptSource source);

  /// Longest side of the image after resizing.
  static const double maxSide = 1600;

  /// JPEG quality of the resized image.
  static const int quality = 80;

  /// Heaviest image accepted (1 MB).
  static const int maxBytes = 1024 * 1024;
}

/// [ReceiptPicker] over `image_picker`, which resizes and compresses the
/// image itself.
// DECISIÓN: no compression package. `image_picker` already scales the image
// to 1600 px and re-encodes it as JPEG at 80 %, which leaves a receipt photo
// well under 1 MB; anything still heavier is refused with a message.
class DeviceReceiptPicker implements ReceiptPicker {
  DeviceReceiptPicker({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedReceipt?> pick(ReceiptSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        ReceiptSource.camera => ImageSource.camera,
        ReceiptSource.gallery => ImageSource.gallery,
      },
      maxWidth: ReceiptPicker.maxSide,
      maxHeight: ReceiptPicker.maxSide,
      imageQuality: ReceiptPicker.quality,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    final bytes = await file.length();
    if (bytes > ReceiptPicker.maxBytes) {
      throw const MovementAttachmentTooLarge();
    }
    return PickedReceipt(path: file.path, name: file.name, bytes: bytes);
  }
}
