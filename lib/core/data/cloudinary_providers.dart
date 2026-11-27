import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'cloudinary_image_uploader.dart';

part 'cloudinary_providers.g.dart';

/// Cloudinary uploader configured from `.env` (loaded by app startup).
@Riverpod(keepAlive: true)
CloudinaryImageUploader cloudinaryImageUploader(Ref ref) =>
    CloudinaryImageUploader(
      cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
      uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
    );
