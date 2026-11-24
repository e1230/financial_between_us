import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/sign_in_tracker.dart';

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
    return MaterialApp.router(
      title: 'Financial Between Us',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
