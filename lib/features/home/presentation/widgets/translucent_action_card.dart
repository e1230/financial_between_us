import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../../core/widgets/gradient_border_box.dart';
import '../home_metrics.dart';
import '../home_text_styles.dart';

/// Frosted card of the empty Home (it sits over the rim of the arc, so the
/// blur shows): an icon with a gradient border, a title, a description and
/// a chevron.
// Exception to "no translucency": requested by the project owner.
class TranslucentActionCard extends StatelessWidget {
  const TranslucentActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final radius = BorderRadius.circular(tokens.radiusCard);
    return Semantics(
      button: true,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: HomeMetrics.cardBlur,
            sigmaY: HomeMetrics.cardBlur,
          ),
          child: Material(
            color: tokens.textPrimary.withValues(
              alpha: HomeMetrics.cardFillOpacity,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: tokens.textPrimary.withValues(
                  alpha: HomeMetrics.cardBorderOpacity,
                ),
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: HomeMetrics.cardMinHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(HomeMetrics.cardPadding),
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: HomeMetrics.cardIconBox,
                        child: GradientBorderBox(
                          gradient: GradientBorderBox.brandGradient(context),
                          // DECISIÓN: the handoff's #161616 is the midpoint
                          // between the background and the cards.
                          fill: Color.lerp(
                            tokens.background,
                            tokens.surface,
                            0.5,
                          )!,
                          borderRadius: tokens.radiusCard,
                          child: Icon(
                            icon,
                            size: HomeMetrics.iconSize,
                            color: context.userPalette.userSoft,
                          ),
                        ),
                      ),
                      const SizedBox(width: HomeMetrics.cardIconGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: styles.cardTitle),
                            SizedBox(height: tokens.space1 / 2),
                            Text(description, style: styles.cardText),
                          ],
                        ),
                      ),
                      SizedBox(width: tokens.space1),
                      Icon(
                        Icons.chevron_right,
                        size: HomeMetrics.cardChevronSize,
                        color: tokens.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
