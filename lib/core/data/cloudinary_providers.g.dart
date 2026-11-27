// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloudinary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cloudinary uploader configured from `.env` (loaded by app startup).

@ProviderFor(cloudinaryImageUploader)
final cloudinaryImageUploaderProvider = CloudinaryImageUploaderProvider._();

/// Cloudinary uploader configured from `.env` (loaded by app startup).

final class CloudinaryImageUploaderProvider
    extends
        $FunctionalProvider<
          CloudinaryImageUploader,
          CloudinaryImageUploader,
          CloudinaryImageUploader
        >
    with $Provider<CloudinaryImageUploader> {
  /// Cloudinary uploader configured from `.env` (loaded by app startup).
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
    r'b776ee1dd1e7fb4074359a7a014efa64e6bc9bd6';
