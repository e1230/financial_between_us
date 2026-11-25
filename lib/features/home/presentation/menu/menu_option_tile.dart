import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';
import '../home_text_styles.dart';

/// A row of the avatar menu: icon, title, optional description and a
/// chevron. A [destructive] row is red and has no chevron.
class MenuOptionTile extends StatelessWidget {
  const MenuOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.description,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final color = destructive ? tokens.negative : tokens.textPrimary;
    final text = description;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: HomeMetrics.menuOptionMinHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.space3,
              vertical: HomeMetrics.actionPadding,
            ),
            child: Row(
              children: [
                Icon(icon, size: HomeMetrics.menuIconSize, color: color),
                const SizedBox(width: HomeMetrics.menuOptionIconGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: styles.menuOption.copyWith(color: color),
                      ),
                      if (text != null) Text(text, style: styles.detail),
                    ],
                  ),
                ),
                if (!destructive)
                  Icon(
                    Icons.chevron_right,
                    size: HomeMetrics.menuChevronSize,
                    color: tokens.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
