import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Placeholder of a screen that belongs to a future module:
/// "{Nombre} (pendiente)".
// TODO: replace each use with the real screen when its module is built.
class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key, required this.name});

  /// Visible name of the screen, like "Cuentas".
  final String name;

  static const double backIconSize = 24;
  static const double backInset = 4;
  static const String back = 'Volver';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(tokens.space3),
                child: Text(
                  '$name (pendiente)',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            if (canPop)
              Positioned(
                top: tokens.space1,
                left: backInset,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: back,
                  icon: Icon(
                    Icons.arrow_back,
                    size: backIconSize,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
