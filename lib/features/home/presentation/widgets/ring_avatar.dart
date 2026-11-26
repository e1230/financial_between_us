import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/user_palette.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../profile/domain/user_profile.dart';
import '../home_metrics.dart';

/// The user's avatar inside a ring of their color: 44 dp in the header and
/// 64 dp in the menu.
///
/// It sizes itself to its constraints (the smallest side), so during the
/// Hero flight between both sizes the ring gap and the initial interpolate
/// with it.
class RingAvatar extends StatelessWidget {
  const RingAvatar({super.key, required this.profile, this.ring = 1});

  /// `null` while the profile loads.
  final UserProfile? profile;

  /// How much of the ring shows, from 1 (ring and gap) to 0 (only the
  /// photo, like the avatar of the profile tab). Used by the Hero flight
  /// from the menu to the profile tab.
  final double ring;

  /// Hero tag shared by the header, the menu and the profile tab.
  static const String heroTag = 'fbu-avatar';

  /// Gap between ring and photo at 44 dp (3) and at 64 dp (4).
  static double gapFor(double size) {
    final t =
        ((size - HomeMetrics.headerAvatarSize) /
                (HomeMetrics.menuAvatarSize - HomeMetrics.headerAvatarSize))
            .clamp(0.0, 1.0);
    return lerpDouble(
      HomeMetrics.headerAvatarGap,
      HomeMetrics.menuAvatarGap,
      t,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.userPalette;
    final photoUrl = profile?.photoUrl;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final visible = ring.clamp(0.0, 1.0);
        final inset = (HomeMetrics.headerAvatarRing + gapFor(size)) * visible;
        return Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(inset),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // A zero-width border would still paint a hairline.
            border: visible == 0
                ? null
                : Border.all(
                    color: palette.userColor,
                    width: HomeMetrics.headerAvatarRing * visible,
                  ),
          ),
          child: UserAvatar(
            initial: profile?.initial ?? '',
            color: palette.userColor,
            size: size - inset * 2,
            image: photoUrl == null ? null : NetworkImage(photoUrl),
          ),
        );
      },
    );
  }
}
