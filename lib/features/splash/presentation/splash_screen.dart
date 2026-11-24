import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/startup/app_startup.dart';
import '../../../core/startup/initial_destination.dart';
import '../../onboarding/presentation/walkthrough_pages.dart';
import 'fbu_splash_animation.dart';
import 'startup_error_view.dart';

/// First screen of the app: plays the animated splash while app startup runs
/// and the [InitialDestination] is resolved, then replaces itself with it.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The first walkthrough photo must be ready when the splash fades out.
    if (!_precached) {
      _precached = true;
      precacheImage(walkthroughPages.first.imageProvider(context), context);
    }
  }

  void _retry() {
    ref
      ..invalidate(appStartupProvider)
      ..invalidate(initialDestinationProvider);
  }

  void _navigate(InitialDestination destination) {
    // DECISIÓN: `go` replaces the stack, so back never returns to the splash.
    context.go(switch (destination) {
      InitialDestination.home => AppRoutes.home,
      InitialDestination.walkthrough => AppRoutes.walkthrough,
      InitialDestination.welcome => AppRoutes.welcome,
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(initialDestinationProvider, (previous, next) {
      if (next case AsyncError(:final error, :final stackTrace)) {
        developer.log(
          'App startup failed',
          name: 'fbu.startup',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });

    final destination = ref.watch(initialDestinationProvider);
    if (destination.hasError && !destination.isLoading) {
      return StartupErrorView(onRetry: _retry);
    }

    return FbuSplashAnimation(
      ready: destination.hasValue && !destination.isLoading,
      onFinished: () => _navigate(destination.requireValue),
    );
  }
}
