import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme_provider.dart';
import 'core/theme/app_tokens.dart';
import 'features/auth/data/sign_in_tracker.dart';
import 'features/groups/data/groups_providers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge: draw behind transparent status and gesture navigation bars.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase and .env are loaded by `appStartupProvider` while the splash
  // animation plays.
  runApp(const ProviderScope(child: FbuApp()));
}

class FbuApp extends ConsumerWidget {
  const FbuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the "has ever signed in" flag in sync for the whole session.
    ref.listen(signInTrackerProvider, (_, _) {});
    // Keeps `userGroups/{uid}` (who shares a group with whom) up to date.
    ref.listen(membershipIndexSyncProvider, (_, _) {});
    // MaterialApp creates the MediaQuery, so read the setting from the
    // platform here.
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    return MaterialApp.router(
      title: 'Financial Between Us',
      debugShowCheckedModeBanner: false,
      // The accent changes with the color of the signed-in user.
      theme: ref.watch(appThemeProvider),
      themeAnimationDuration: reduceMotion
          ? Duration.zero
          : AppTokens.dark.motionMedium,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
