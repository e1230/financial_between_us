import 'package:material_ui/material_ui.dart';

import '../branding/fbu_emblem_geometry.dart';
import '../branding/fbu_logo.dart';
import '../theme/app_tokens.dart';

/// Temporary destination after the splash, until auth/onboarding exist.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.space3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FbuLogo(size: FbuLogoMetrics.compactEmblemSize),
                SizedBox(height: tokens.space4),
                Text('Próximamente', style: textTheme.headlineSmall),
                SizedBox(height: tokens.space1),
                Text(
                  'Aquí irán tus grupos y salidas.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
