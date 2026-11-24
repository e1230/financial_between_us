import 'package:material_ui/material_ui.dart';

import 'background/auth_background_spec.dart';
import 'background/fbu_auth_background.dart';

/// Hosts the auth screens on top of a single [FbuAuthBackground].
///
/// The background lives above the inner navigator ([child]), so moving
/// between auth screens never rebuilds it: only its [variant] changes. It
/// is not inside a [Scaffold], so the keyboard never resizes or moves it.
class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.variant, required this.child});

  final AuthBackgroundVariant variant;

  /// The inner navigator with the auth screens (transparent backgrounds).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FbuAuthBackground(variant: variant),
        child,
      ],
    );
  }
}
