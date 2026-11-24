import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';
import '../auth_text_styles.dart';

/// "── o ──" separator between the main action and Google, 16 dp above and
/// below. Decorative for screen readers.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final line = Expanded(
      child: Container(
        height: AuthMetrics.dividerThickness,
        color: tokens.border,
      ),
    );
    return ExcludeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.space2),
        child: Row(
          children: [
            line,
            const SizedBox(width: AuthMetrics.dividerGap),
            Text(AuthStrings.or, style: AuthTextStyles.of(context).divider),
            const SizedBox(width: AuthMetrics.dividerGap),
            line,
          ],
        ),
      ),
    );
  }
}
