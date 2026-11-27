import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cloudinary_image_uploader.dart';

part 'cloudinary_providers.g.dart';

/// Cloudinary uploader configured from `.env` (loaded by app startup).
/// Without it (e.g. in tests) it is unconfigured and every upload fails
/// with an [ImageUploadException] instead of breaking whoever builds it.
@Riverpod(keepAlive: true)
CloudinaryImageUploader cloudinaryImageUploader(Ref ref) {
  final env = dotenv.isInitialized ? dotenv.env : const <String, String>{};
  return CloudinaryImageUploader(
    cloudName: env['CLOUDINARY_CLOUD_NAME'] ?? '',
    uploadPreset: env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
  );
}
