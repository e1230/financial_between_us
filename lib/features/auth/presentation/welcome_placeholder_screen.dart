import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';

// TODO: replace with the real welcome screen of the auth module (inside the
// auth ShellRoute with the animated background).
/// Temporary welcome (auth entry) screen, target of the walkthrough.
class WelcomePlaceholderScreen extends StatelessWidget {
  const WelcomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.space3),
            child: Text(
              'Bienvenida (pendiente)',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
