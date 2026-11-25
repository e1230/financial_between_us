import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../auth/presentation/auth_metrics.dart';
import '../profile_metrics.dart';
import '../profile_strings.dart';

/// Placeholder of "Completa tu perfil" while the profile loads.
class CompleteProfileSkeleton extends StatelessWidget {
  const CompleteProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final fill = tokens.surfaceVariant;
    return Semantics(
      label: ProfileStrings.loading,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: ProfileMetrics.avatarSize,
              height: ProfileMetrics.avatarSize,
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
            ),
            SizedBox(height: tokens.space3),
            Container(
              height: AuthMetrics.fieldHeight,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(tokens.radiusInput),
              ),
            ),
            SizedBox(height: tokens.space3),
            Wrap(
              spacing:
                  ProfileMetrics.swatchTouchTarget -
                  ProfileMetrics.swatchSize +
                  ProfileMetrics.swatchGap,
              children: [
                for (var i = 0; i < 5; i++)
                  Container(
                    width: ProfileMetrics.swatchSize,
                    height: ProfileMetrics.swatchSize,
                    decoration: BoxDecoration(
                      color: fill,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
