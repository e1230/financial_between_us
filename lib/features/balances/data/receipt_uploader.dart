import '../../../core/data/cloudinary_image_uploader.dart';
import '../domain/ledger_movement.dart';
import '../domain/movement_failure.dart';

/// Uploads the image attached to a movement.
abstract interface class ReceiptUploader {
  /// Uploads the image at [filePath] of a movement of [groupId]. Throws
  /// [MovementAttachmentFailure].
  Future<MovementAttachment> upload(String filePath, {required String groupId});
}

/// Receipts uploaded to Cloudinary, one folder per group.
class CloudinaryReceiptUploader implements ReceiptUploader {
  CloudinaryReceiptUploader(this._uploader);

  final CloudinaryImageUploader _uploader;

  /// Cloudinary folder of the receipts of [groupId].
  static String folderFor(String groupId) => 'fbu/receipts/$groupId';

  @override
  Future<MovementAttachment> upload(
    String filePath, {
    required String groupId,
  }) async {
    try {
      final image = await _uploader.upload(
        filePath,
        folder: folderFor(groupId),
      );
      return MovementAttachment(
        url: image.url,
        width: image.width,
        height: image.height,
        bytes: image.bytes,
      );
    } on ImageUploadException {
      throw const MovementAttachmentFailure();
    }
  }
}
