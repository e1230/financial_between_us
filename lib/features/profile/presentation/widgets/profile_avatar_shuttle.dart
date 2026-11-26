import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../home/presentation/widgets/ring_avatar.dart';
import '../../data/profile_providers.dart';

/// Flight of the avatar between the menu (64 dp, with its ring) and the
/// profile tab (96 dp, without a ring): the ring fades out as it grows.
///
/// [animation] is the menu route's: 1 while the menu shows, 0 once it is
/// gone. So does the ring.
Widget profileAvatarShuttle(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) => Consumer(
  builder: (context, ref, _) {
    final profile = ref.watch(currentUserProfileProvider).value;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) =>
          RingAvatar(profile: profile, ring: animation.value),
    );
  },
);
