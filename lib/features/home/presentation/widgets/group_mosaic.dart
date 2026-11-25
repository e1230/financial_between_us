import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../home_metrics.dart';

/// 40 dp rounded square with a group's initials. Its colors cycle through a
/// fixed palette by the group's position in the list.
class GroupMosaic extends StatelessWidget {
  const GroupMosaic({super.key, required this.initials, required this.index});

  final String initials;
  final int index;

  /// Number of color pairs before the palette repeats.
  static const int paletteSize = 3;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    final (background, foreground) = switch (index % paletteSize) {
      0 => (palette.userTint, palette.userSoft),
      1 => (
        tokens.glowBright.withValues(alpha: HomeMetrics.tileGreenOpacity),
        tokens.tileGreenText,
      ),
      _ => (
        tokens.glowTeal.withValues(alpha: HomeMetrics.tileTealOpacity),
        tokens.tileTealText,
      ),
    };
    return Container(
      width: HomeMetrics.selectorTile,
      height: HomeMetrics.selectorTile,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
      ),
      child: Text(
        initials,
        textScaler: TextScaler.noScaling,
        style: Theme.of(context).textTheme.titleSmall!
            .copyWith(color: foreground),
      ),
    );
  }
}
