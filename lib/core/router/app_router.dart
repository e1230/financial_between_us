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
import '../../features/home/presentation/home_metrics.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/home_strings.dart';
import '../../features/home/presentation/menu/avatar_menu_screen.dart';
import '../../features/onboarding/presentation/walkthrough_screen.dart';
import '../../features/profile/presentation/complete_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../theme/app_tokens.dart';
import '../widgets/pending_screen.dart';

part 'app_router.g.dart';

/// Route paths of the app.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String walkthrough = '/walkthrough';

  // Tabs of the signed-in shell.
  static const String home = '/home';
  static const String events = '/events';
  static const String balances = '/balances';
  static const String profile = '/profile';

  // Pages over the shell (no bottom bar).
  static const String menu = '/menu';
  static const String accounts = '/accounts';
  static const String groups = '/groups';
  static const String newEvent = '/events/new';
  static const String newMovement = '/movements/new';
  static const String newIncome = '/movements/new/income';
  static const String newPayment = '/movements/new/payment';
  static const String newDebt = '/movements/new/debt';

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

/// Navigator of the whole app; pages over the shell are pushed here.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      homeShellRoute(),
      ...overShellRoutes(),
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

/// The signed-in shell: Inicio, Eventos, Saldos and Perfil, each keeping
/// its state, over the bottom bar. Public so tests can mount it.
StatefulShellRoute homeShellRoute() {
  return StatefulShellRoute.indexedStack(
    pageBuilder: (context, state, navigationShell) => _fadePage(
      context: context,
      state: state,
      child: HomeShell(navigationShell: navigationShell),
    ),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.events,
            builder: (context, state) =>
                const PendingScreen(name: HomeStrings.tabEvents),
            routes: [
              _pending(
                _child(AppRoutes.newEvent, of: AppRoutes.events),
                HomeStrings.addEvent,
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.balances,
            builder: (context, state) =>
                const PendingScreen(name: HomeStrings.tabBalances),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Pages that cover the shell: the avatar menu and the screens of future
/// modules. Public so tests can mount them.
List<RouteBase> overShellRoutes() => [
  GoRoute(
    path: AppRoutes.menu,
    parentNavigatorKey: rootNavigatorKey,
    pageBuilder: (context, state) => _menuPage(context, state),
  ),
  _pending(AppRoutes.accounts, HomeStrings.accounts),
  _pending(AppRoutes.groups, HomeStrings.menuGroups),
  GoRoute(
    path: AppRoutes.newMovement,
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) =>
        const PendingScreen(name: HomeStrings.addMovement),
    routes: [
      _pending(
        _child(AppRoutes.newIncome, of: AppRoutes.newMovement),
        HomeStrings.addIncome,
      ),
      _pending(
        _child(AppRoutes.newPayment, of: AppRoutes.newMovement),
        HomeStrings.addPayment,
      ),
      _pending(
        _child(AppRoutes.newDebt, of: AppRoutes.newMovement),
        HomeStrings.addDebt,
      ),
    ],
  ),
];

/// A page of a future module, over the shell.
// TODO: replace each one with its screen when the module is built.
GoRoute _pending(String path, String name) => GoRoute(
  path: path,
  parentNavigatorKey: rootNavigatorKey,
  builder: (context, state) => PendingScreen(name: name),
);

/// The avatar menu: 450 ms, during which the avatar flies as a Hero and the
/// page fades in. With `MediaQuery.disableAnimations`, a 150 ms fade.
CustomTransitionPage<void> _menuPage(
  BuildContext context,
  GoRouterState state,
) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  final duration = reduceMotion
      ? HomeMetrics.reducedMotionFade
      : HomeMetrics.menuTransition;
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: const AvatarMenuScreen(),
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.fastOutSlowIn,
          ),
          child: child,
        ),
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
