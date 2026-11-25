import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// Title (Satoshi Bold 22/28) and subtitle (Inter 14/20 at 60 %) of a
/// popup.
class DialogHeading extends StatelessWidget {
  const DialogHeading({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final styles = HomeTextStyles.of(context);
    final text = subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: Text(title, style: styles.dialogTitle)),
        if (text != null) ...[
          SizedBox(height: context.tokens.space1),
          Text(text, style: styles.dialogSubtitle),
        ],
      ],
    );
  }
}

/// A 56 dp circle with a 28 dp icon on a 12 % tint, at the top of a result
/// popup ("Grupo creado", "Solicitud enviada").
class DialogBadge extends StatelessWidget {
  const DialogBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: HomeMetrics.successCircle,
        height: HomeMetrics.successCircle,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: HomeMetrics.successIcon, color: color),
      ),
    );
  }
}

/// "Cancelar": a 48 dp text button under the main one of a popup.
class DialogCancelButton extends StatelessWidget {
  const DialogCancelButton({
    super.key,
    required this.onPressed,
    this.label = HomeStrings.cancel,
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      height: HomeMetrics.textButtonHeight,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: tokens.textPrimary,
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: Text(label),
      ),
    );
  }
}
