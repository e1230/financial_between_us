// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloudinary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cloudinary uploader configured from `.env` (loaded by app startup).
/// Without it (e.g. in tests) it is unconfigured and every upload fails
/// with an [ImageUploadException] instead of breaking whoever builds it.

@ProviderFor(cloudinaryImageUploader)
final cloudinaryImageUploaderProvider = CloudinaryImageUploaderProvider._();

/// Cloudinary uploader configured from `.env` (loaded by app startup).
/// Without it (e.g. in tests) it is unconfigured and every upload fails
/// with an [ImageUploadException] instead of breaking whoever builds it.

final class CloudinaryImageUploaderProvider
    extends
        $FunctionalProvider<
          CloudinaryImageUploader,
          CloudinaryImageUploader,
          CloudinaryImageUploader
        >
    with $Provider<CloudinaryImageUploader> {
  /// Cloudinary uploader configured from `.env` (loaded by app startup).
  /// Without it (e.g. in tests) it is unconfigured and every upload fails
  /// with an [ImageUploadException] instead of breaking whoever builds it.
  CloudinaryImageUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cloudinaryImageUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cloudinaryImageUploaderHash();

  @$internal
  @override
  $ProviderElement<CloudinaryImageUploader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CloudinaryImageUploader create(Ref ref) {
    return cloudinaryImageUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CloudinaryImageUploader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CloudinaryImageUploader>(value),
    );
  }
}

String _$cloudinaryImageUploaderHash() =>
    r'98565587417953538e272d6697797402b04a4a6f';
