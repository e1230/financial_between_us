import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../../core/widgets/gradient_border_box.dart';
import '../home_metrics.dart';
import '../home_text_styles.dart';

/// "Agregar ingreso / pago / deuda": a card with a gradient border. Pressed,
/// it scales to 0.97 and its border grows from 1.5 to 2 dp (100 ms).
class QuickActionButton extends StatefulWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (value != _pressed) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : HomeMetrics.pressDuration;
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? HomeMetrics.pressedScale : 1,
          duration: duration,
          // At least 88 dp; taller with large text (the row gives all three
          // buttons the height of the tallest).
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: HomeMetrics.actionHeight,
            ),
            child: GradientBorderBox(
              gradient: GradientBorderBox.brandGradient(context),
              fill: tokens.surface,
              borderRadius: tokens.radiusCard,
              borderWidth: _pressed
                  ? HomeMetrics.gradientBorderPressed
                  : HomeMetrics.gradientBorder,
              duration: duration,
              child: Padding(
                padding: const EdgeInsets.all(HomeMetrics.actionPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: HomeMetrics.actionIconCircle,
                      height: HomeMetrics.actionIconCircle,
                      decoration: BoxDecoration(
                        color: palette.userTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: HomeMetrics.actionIconSize,
                        color: palette.userSoft,
                      ),
                    ),
                    const SizedBox(height: HomeMetrics.actionGap),
                    Text(
                      widget.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HomeTextStyles.of(context).action,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
