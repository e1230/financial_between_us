import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../profile/domain/user_profile.dart';
import '../groups_metrics.dart';

/// Avatar of a member row: the photo, or the initial over the member's
/// color. A neutral circle while the profile loads.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({super.key, required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    if (profile == null) {
      return Container(
        width: GroupsMetrics.memberAvatar,
        height: GroupsMetrics.memberAvatar,
        decoration: BoxDecoration(
          color: context.tokens.surfaceVariant,
          shape: BoxShape.circle,
        ),
      );
    }
    final photoUrl = profile.photoUrl;
    return UserAvatar(
      initial: profile.initial,
      color: Color(profile.colorValue),
      size: GroupsMetrics.memberAvatar,
      image: photoUrl == null ? null : NetworkImage(photoUrl),
    );
  }
}
