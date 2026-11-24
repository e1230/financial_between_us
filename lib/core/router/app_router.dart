import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/welcome_placeholder_screen.dart';
import '../../features/onboarding/presentation/walkthrough_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../theme/app_tokens.dart';
import 'home_placeholder_screen.dart';

part 'app_router.g.dart';

/// Route paths of the app.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String walkthrough = '/walkthrough';
  static const String welcome = '/welcome';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const HomePlaceholderScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.walkthrough,
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const WalkthroughScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) => _fadePage(
          context: context,
          state: state,
          child: const WelcomePlaceholderScreen(),
        ),
      ),
    ],
  );
}

/// Cross-fade transition that honors `MediaQuery.disableAnimations`.
CustomTransitionPage<void> _fadePage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : context.tokens.motionMedium;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
