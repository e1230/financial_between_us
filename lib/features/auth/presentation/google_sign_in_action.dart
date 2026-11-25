import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../data/auth_repository.dart';
import '../domain/auth_failure.dart';
import 'auth_strings.dart';

/// "Continuar con Google" of sign-up and sign-in (both do the same).
///
/// Navigates to where the session belongs (the first time: choose a
/// nickname). Returns the message for the banner if it failed, or `null`
/// when it worked or the user closed the Google dialog.
Future<String?> continueWithGoogle(BuildContext context, WidgetRef ref) async {
  try {
    final destination = await ref
        .read(authRepositoryProvider)
        .signInWithGoogle();
    if (destination != null && context.mounted) {
      context.go(AppRoutes.forSession(destination));
    }
    return null;
  } on AuthFailure catch (failure) {
    return AuthStrings.authFailure(failure);
  }
}
