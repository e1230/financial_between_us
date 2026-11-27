import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../profile/domain/user_profile.dart';

/// Hero tag of a person's avatar, from the list row to the detail.
String personAvatarTag(String uid) => 'saldo-avatar-$uid';

/// Avatar of a person in the balances screens: their photo, or the initial
/// over their color (`users/{uid}.color`). A neutral circle while the
/// profile loads. With [heroTag] it flies between the list and the detail
/// (not with `MediaQuery.disableAnimations`).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.profile,
    required this.size,
    this.heroTag,
  });

  final UserProfile? profile;
  final double size;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    final photoUrl = profile?.photoUrl;
    final Widget avatar = profile == null
        ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: context.tokens.surfaceVariant,
              shape: BoxShape.circle,
            ),
          )
        : UserAvatar(
            initial: profile.initial,
            color: Color(profile.colorValue),
            size: size,
            image: photoUrl == null ? null : NetworkImage(photoUrl),
          );
    final tag = heroTag;
    if (tag == null) return avatar;
    return HeroMode(
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: Hero(tag: tag, child: avatar),
    );
  }
}
