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
    this.heroTag,
    this.flightShuttleBuilder,
  });

  final String initial;
  final Color color;
  final ImageProvider? image;
  final VoidCallback onTap;
  final bool enabled;

  /// When set, the photo is a [Hero] with this tag (the badge is not part of
  /// the flight).
  final Object? heroTag;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

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
              _hero(
                UserAvatar(
                  initial: initial,
                  color: color,
                  image: image,
                  size: ProfileMetrics.avatarSize,
                  semanticsLabel: ProfileStrings.avatarLabel,
                ),
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

  Widget _hero(Widget avatar) {
    final tag = heroTag;
    if (tag == null) return avatar;
    return Hero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      child: avatar,
    );
  }
}
