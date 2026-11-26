import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../home/presentation/home_metrics.dart';
import '../groups_metrics.dart';
import '../groups_strings.dart';

/// Placeholder cards while the groups load.
class GroupsSkeleton extends StatelessWidget {
  const GroupsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget bar(double width) => Container(
      width: width,
      height: HomeMetrics.skeletonLine,
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
    );
    return Semantics(
      label: GroupsStrings.loading,
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var i = 0; i < HomeMetrics.skeletonRows; i++)
              Padding(
                padding: EdgeInsets.only(bottom: tokens.space1),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: GroupsMetrics.cardMinHeight,
                  ),
                  padding: EdgeInsets.all(tokens.space2),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: BorderRadius.circular(tokens.radiusCard),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: HomeMetrics.selectorTile,
                        height: HomeMetrics.selectorTile,
                        decoration: BoxDecoration(
                          color: tokens.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            tokens.radiusCard,
                          ),
                        ),
                      ),
                      SizedBox(width: tokens.space2),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              bar(
                                constraints.maxWidth *
                                    GroupsMetrics.skeletonTitleWidth,
                              ),
                              SizedBox(height: tokens.space1),
                              bar(
                                constraints.maxWidth *
                                    GroupsMetrics.skeletonDetailWidth,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
