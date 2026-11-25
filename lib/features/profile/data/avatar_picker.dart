import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Where the avatar photo comes from.
enum AvatarSource { gallery, camera }

/// Colors and texts of the native crop screen (uCrop).
@immutable
class AvatarCropStyle {
  const AvatarCropStyle({
    required this.title,
    required this.background,
    required this.toolbar,
    required this.foreground,
    required this.active,
  });

  final String title;
  final Color background;
  final Color toolbar;
  final Color foreground;
  final Color active;
}

/// Lets the user take or choose a photo and crop it square.
abstract interface class AvatarPicker {
  /// Path of the cropped image, or `null` if the user cancelled.
  Future<String?> pick(AvatarSource source, AvatarCropStyle style);
}

class DeviceAvatarPicker implements AvatarPicker {
  DeviceAvatarPicker({ImagePicker? picker, ImageCropper? cropper})
    : _picker = picker ?? ImagePicker(),
      _cropper = cropper ?? ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;

  /// Avatars are shown small: 512 px is plenty and keeps uploads light.
  static const int _maxSide = 512;
  static const int _quality = 85;

  @override
  Future<String?> pick(AvatarSource source, AvatarCropStyle style) async {
    final photo = await _picker.pickImage(
      source: switch (source) {
        AvatarSource.gallery => ImageSource.gallery,
        AvatarSource.camera => ImageSource.camera,
      },
      preferredCameraDevice: CameraDevice.front,
      maxWidth: _maxSide * 2,
      maxHeight: _maxSide * 2,
      imageQuality: _quality,
    );
    if (photo == null) return null;

    final cropped = await _cropper.cropImage(
      sourcePath: photo.path,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: _quality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: style.title,
          toolbarColor: style.toolbar,
          toolbarWidgetColor: style.foreground,
          backgroundColor: style.background,
          activeControlsWidgetColor: style.active,
          statusBarLight: false,
          navBarLight: false,
          cropStyle: CropStyle.circle,
          lockAspectRatio: true,
          hideBottomControls: true,
          initAspectRatio: CropAspectRatioPreset.square,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
      ],
    );
    return cropped?.path;
  }
}
