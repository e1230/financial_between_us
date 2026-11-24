import 'package:material_ui/material_ui.dart';

import '../../../core/branding/fbu_emblem_geometry.dart';
import '../../../core/branding/fbu_logo.dart';
import '../../../core/theme/app_tokens.dart';

/// Shown instead of the splash animation when app startup fails.
class StartupErrorView extends StatelessWidget {
  const StartupErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: tokens.brandBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.space3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FbuLogo(
                  size: FbuLogoMetrics.compactEmblemSize,
                  showWordmark: false,
                ),
                SizedBox(height: tokens.space4),
                Text(
                  'No pudimos iniciar la app',
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.space1),
                Text(
                  'Revisa tu conexión e inténtalo de nuevo.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: tokens.space3),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
