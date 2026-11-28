import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import 'notifications_providers.dart';

/// Opens the route of a tapped notification over whatever is on screen.
///
/// During the splash it does nothing: the splash goes there itself when the
/// session lands on the Home (a notification that launched the app). On
/// the sign-in screens the route is dropped (it was for a session that is
/// no longer there).
class NotificationRouteListener extends ConsumerWidget {
  const NotificationRouteListener({super.key, required this.child});

  final Widget child;

  static bool _isSignedInPath(String path) =>
      path != AppRoutes.walkthrough &&
      path != AppRoutes.welcome &&
      !path.startsWith('${AppRoutes.welcome}/') &&
      path != AppRoutes.completeProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sets the local notifications up (and reads the launch tap).
    ref.listen(notificationsSetupProvider, (_, _) {});
    ref.listen(pendingNotificationRouteProvider, (_, route) {
      if (route == null) return;
      final router = ref.read(appRouterProvider);
      final path = router.routerDelegate.currentConfiguration.uri.path;
      if (path.isEmpty || path == AppRoutes.splash) return;
      final pending = ref
          .read(pendingNotificationRouteProvider.notifier)
          .take();
      if (pending != null && _isSignedInPath(path)) router.push(pending);
    });
    return child;
  }
}
