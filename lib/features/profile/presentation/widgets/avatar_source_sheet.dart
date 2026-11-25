import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../profile_strings.dart';

/// What to do with the avatar photo.
enum AvatarAction { gallery, camera, remove }

/// Bottom sheet with the avatar options. `null` when dismissed.
Future<AvatarAction?> showAvatarSourceSheet(
  BuildContext context, {
  required bool canRemove,
}) {
  final tokens = context.tokens;
  return showModalBottomSheet<AvatarAction>(
    context: context,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    builder: (context) {
      Widget option(AvatarAction action, IconData icon, String label) =>
          ListTile(
            leading: Icon(icon, color: tokens.textPrimary),
            title: Text(label),
            onTap: () => Navigator.pop(context, action),
          );
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: tokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(
                AvatarAction.gallery,
                Icons.photo_library_outlined,
                ProfileStrings.fromGallery,
              ),
              option(
                AvatarAction.camera,
                Icons.photo_camera_outlined,
                ProfileStrings.fromCamera,
              ),
              if (canRemove)
                option(
                  AvatarAction.remove,
                  Icons.delete_outline,
                  ProfileStrings.removePhoto,
                ),
            ],
          ),
        ),
      );
    },
  );
}
