import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../profile_metrics.dart';
import '../profile_strings.dart';

/// Large avatar with a camera badge; tapping it changes the photo.
class AvatarEditor extends StatelessWidget {
  const AvatarEditor({
    super.key,
    required this.initial,
    required this.color,
    required this.onTap,
    this.image,
    this.enabled = true,
  });

  final String initial;
  final Color color;
  final ImageProvider? image;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      button: true,
      label: ProfileStrings.changePhoto,
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: ProfileMetrics.avatarSize / 2,
        child: SizedBox.square(
          dimension: ProfileMetrics.avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(
                initial: initial,
                color: color,
                image: image,
                size: ProfileMetrics.avatarSize,
                semanticsLabel: ProfileStrings.avatarLabel,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: ProfileMetrics.avatarBadgeSize,
                  height: ProfileMetrics.avatarBadgeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tokens.surfaceVariant,
                    border: Border.all(
                      color: tokens.background,
                      width: ProfileMetrics.avatarBadgeBorder,
                    ),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: ProfileMetrics.avatarBadgeIconSize,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
