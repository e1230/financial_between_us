import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// The header pill with the active group's name and a chevron that turns
/// 180° while the selector is open.
class GroupPill extends StatelessWidget {
  const GroupPill({
    super.key,
    required this.groupName,
    required this.expanded,
    required this.onTap,
  });

  /// `null` without groups ("Sin grupo").
  final String? groupName;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final name = groupName;
    final glass = tokens.textPrimary;
    return Semantics(
      button: true,
      expanded: expanded,
      label: name == null
          ? HomeStrings.groupPillEmpty
          : HomeStrings.groupPill(name),
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: HomeMetrics.pillMaxWidth,
          minHeight: HomeMetrics.touchTarget,
        ),
        // Hugs the pill vertically so it lines up wherever it is drawn
        // (header or selector overlay).
        child: Center(
          heightFactor: 1,
          child: Material(
            color: expanded
                ? tokens.surfaceVariant
                : glass.withValues(alpha: HomeMetrics.glassFillOpacity),
            shape: StadiumBorder(
              side: BorderSide(
                color: glass.withValues(alpha: HomeMetrics.glassBorderOpacity),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: HomeMetrics.pillHeight,
                padding: const EdgeInsetsDirectional.only(
                  start: HomeMetrics.pillPaddingStart,
                  end: HomeMetrics.pillPaddingEnd,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name ?? HomeStrings.noGroup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.pill.copyWith(
                          color: name == null ? tokens.textSecondary : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: HomeMetrics.pillGap),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: reduceMotion
                          ? Duration.zero
                          : tokens.motionShort,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: HomeMetrics.chevronSize,
                        color: name == null
                            ? tokens.textSecondary
                            : tokens.textPrimary,
                      ),
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
