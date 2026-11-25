import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// A tab of the bottom bar: icon over label. The active one is green with a
/// pill indicator; a disabled one is dimmed and ignores taps.
class BottomTab extends StatelessWidget {
  const BottomTab({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;

  /// `null` disables the tab.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final enabled = onTap != null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final color = !enabled
        ? tokens.textDisabled
        : selected
        ? tokens.positive
        : tokens.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      hint: enabled ? null : HomeStrings.unavailable,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: HomeMetrics.tabWidth / 2,
        child: SizedBox(
          width: HomeMetrics.tabWidth,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: HomeMetrics.tabMinHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: reduceMotion ? Duration.zero : tokens.motionFast,
                  width: HomeMetrics.tabIndicatorWidth,
                  height: HomeMetrics.tabIndicatorHeight,
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: tokens.positive.withValues(
                      alpha: selected ? HomeMetrics.tabIndicatorOpacity : 0,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: HomeMetrics.tabIconSize,
                    color: color,
                  ),
                ),
                const SizedBox(height: HomeMetrics.tabGap),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: HomeTextStyles.of(context).tab.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
