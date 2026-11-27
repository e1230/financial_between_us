import '../../../core/data/cloudinary_image_uploader.dart';

/// The avatar could not be uploaded (network, preset or server error).
class AvatarUploadException implements Exception {
  const AvatarUploadException(this.message);

  final String message;

  @override
  String toString() => 'AvatarUploadException: $message';
}

/// Uploads avatar images and returns their public URL.
abstract interface class AvatarUploader {
  /// Uploads the image at [filePath]. Throws [AvatarUploadException].
  Future<String> upload(String filePath);
}

/// Avatars uploaded to Cloudinary with [CloudinaryImageUploader].
class CloudinaryAvatarUploader implements AvatarUploader {
  CloudinaryAvatarUploader(this._uploader);

  final CloudinaryImageUploader _uploader;

  /// Cloudinary folder of the avatars.
  static const String folder = 'fbu/avatars';

  @override
  Future<String> upload(String filePath) async {
    try {
      return (await _uploader.upload(filePath, folder: folder)).url;
    } on ImageUploadException catch (error) {
      throw AvatarUploadException(error.message);
    }
  }
}
