import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/startup/app_startup.dart';
import 'fbu_splash_animation.dart';
import 'startup_error_view.dart';

/// First screen of the app: plays the animated splash while
/// [appStartupProvider] runs, then navigates to home.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appStartupProvider, (previous, next) {
      if (next case AsyncError(:final error, :final stackTrace)) {
        developer.log(
          'App startup failed',
          name: 'fbu.startup',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });

    final startup = ref.watch(appStartupProvider);
    if (startup.hasError && !startup.isLoading) {
      return StartupErrorView(
        onRetry: () => ref.invalidate(appStartupProvider),
      );
    }

    return FbuSplashAnimation(
      ready: startup.hasValue && !startup.isLoading,
      onFinished: () => context.go(AppRoutes.home),
    );
  }
}
