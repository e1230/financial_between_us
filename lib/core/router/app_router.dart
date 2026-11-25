import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/session_destination.dart';
import '../../features/auth/presentation/auth_page_transition.dart';
import '../../features/auth/presentation/auth_shell.dart';
import '../../features/auth/presentation/background/auth_background_spec.dart';
import '../../features/auth/presentation/screens/choose_username_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/recover_screen.dart';
import '../../features/auth/presentation/screens/recover_sent_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/walkthrough_screen.dart';
import '../../features/profile/presentation/complete_profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../theme/app_tokens.dart';
import 'home_placeholder_screen.dart';

part 'app_router.g.dart';

/// Route paths of the app.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String walkthrough = '/walkthrough';

  // Auth (nested so the back stack follows the auth flow).
  static const String welcome = '/auth';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String recover = '/auth/login/recover';
  static const String recoverSent = '/auth/login/recover/sent';
  static const String chooseUsername = '/auth/username';

  /// Optional profile data after signing up. Outside `/auth`, so back never
  /// returns to the sign-in screens.
  static const String completeProfile = '/profile/complete';

  /// Route of a signed-in user's [SessionDestination].
  static String forSession(SessionDestination destination) =>
      switch (destination) {
        SessionDestination.home => home,
        SessionDestination.chooseNickname => chooseUsername,
        SessionDestination.completeProfile => completeProfile,
      };
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
      authShellRoute(),
    ],
  );
}

/// Auth screens (and "Completa tu perfil") over one shared animated
/// background. Sub-routes are nested so `go` builds the back stack of the
/// flow (e.g. sent → recover → login → welcome). Public so tests can mount
/// the flow without the splash.
ShellRoute authShellRoute() {
  return ShellRoute(
    pageBuilder: (context, state, child) => _fadePage(
      context: context,
      state: state,
      child: AuthShell(
        variant: state.uri.path == AppRoutes.welcome
            ? AuthBackgroundVariant.welcome
            : AuthBackgroundVariant.form,
        child: child,
      ),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder: (context, state) => authPage(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
        routes: [
          GoRoute(
            path: _child(AppRoutes.register, of: AppRoutes.welcome),
            pageBuilder: (context, state) => authPage(
              context: context,
              state: state,
              child: const RegisterScreen(),
            ),
          ),
          GoRoute(
            path: _child(AppRoutes.login, of: AppRoutes.welcome),
            pageBuilder: (context, state) => authPage(
              context: context,
              state: state,
              child: const LoginScreen(),
            ),
            routes: [
              GoRoute(
                path: _child(AppRoutes.recover, of: AppRoutes.login),
                pageBuilder: (context, state) => authPage(
                  context: context,
                  state: state,
                  child: const RecoverScreen(),
                ),
                routes: [
                  GoRoute(
                    path: _child(AppRoutes.recoverSent, of: AppRoutes.recover),
                    pageBuilder: (context, state) => authPage(
                      context: context,
                      state: state,
                      child: RecoverSentScreen(
                        email: state.extra is String
                            ? state.extra! as String
                            : '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: _child(AppRoutes.chooseUsername, of: AppRoutes.welcome),
            pageBuilder: (context, state) => authPage(
              context: context,
              state: state,
              child: const ChooseUsernameScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        pageBuilder: (context, state) => authPage(
          context: context,
          state: state,
          child: const CompleteProfileScreen(),
        ),
      ),
    ],
  );
}

/// Relative path of a nested route: `_child('/a/b', of: '/a')` → `b`.
String _child(String path, {required String of}) {
  assert(path.startsWith('$of/'), '$path is not under $of');
  return path.substring(of.length + 1);
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
