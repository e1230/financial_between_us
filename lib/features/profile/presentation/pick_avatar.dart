import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/avatar_picker.dart';
import '../data/profile_providers.dart';
import 'profile_strings.dart';
import 'widgets/avatar_source_sheet.dart';

/// What the user did with the avatar photo.
sealed class AvatarChange {
  const AvatarChange();
}

/// A new photo, cropped and stored at [path] (not uploaded yet).
final class AvatarPhotoPicked extends AvatarChange {
  const AvatarPhotoPicked(this.path);

  final String path;
}

/// The photo was removed: the avatar goes back to the initial.
final class AvatarPhotoRemoved extends AvatarChange {
  const AvatarPhotoRemoved();
}

/// Shows the avatar options and, for the camera or the gallery, the picker
/// and the crop screen (tinted with [accent]). `null` when the user
/// cancels. Errors of the picker are rethrown.
Future<AvatarChange?> pickAvatar(
  BuildContext context,
  WidgetRef ref, {
  required bool canRemove,
  required Color accent,
}) async {
  final tokens = context.tokens;
  final action = await showAvatarSourceSheet(context, canRemove: canRemove);
  if (action == null || !context.mounted) return null;
  if (action == AvatarAction.remove) return const AvatarPhotoRemoved();

  final path = await ref
      .read(avatarPickerProvider)
      .pick(
        action == AvatarAction.camera
            ? AvatarSource.camera
            : AvatarSource.gallery,
        AvatarCropStyle(
          title: ProfileStrings.cropTitle,
          background: tokens.background,
          toolbar: tokens.surface,
          foreground: tokens.textPrimary,
          active: accent,
        ),
      );
  return path == null ? null : AvatarPhotoPicked(path);
}
