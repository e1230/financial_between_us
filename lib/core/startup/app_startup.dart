import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../firebase_options.dart';

part 'app_startup.g.dart';

/// One-time app initialization, run while the splash is on screen.
///
/// Failures are not retried automatically: the splash shows an error state
/// with a retry button that invalidates this provider.
@Riverpod(keepAlive: true, retry: noStartupRetry)
Future<void> appStartup(Ref ref) async {
  await dotenv.load(fileName: '.env');
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// Disables Riverpod's automatic retry for [appStartup].
Duration? noStartupRetry(int retryCount, Object error) => null;
