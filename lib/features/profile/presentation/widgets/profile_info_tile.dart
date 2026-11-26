import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../auth/presentation/auth_metrics.dart';
import '../../../auth/presentation/auth_text_styles.dart';
import '../profile_metrics.dart';

/// A row of the profile with the look of a text field (label over value)
/// that cannot be edited in place.
///
/// Without [trailing] it shows a lock icon. [helper] goes below the row.
class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.leading,
    this.trailing,
    this.helper,
  });

  final String label;
  final String value;
  final Widget? leading;
  final Widget? trailing;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = AuthTextStyles.of(context);
    final lead = leading;
    final help = helper;
    final action = trailing;

    final row = Container(
      constraints: const BoxConstraints(minHeight: AuthMetrics.fieldHeight),
      padding: EdgeInsets.only(
        left: tokens.space2,
        right: action == null ? tokens.space2 : tokens.space1,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusInput),
      ),
      child: Row(
        children: [
          if (lead != null) ...[
            lead,
            const SizedBox(width: ProfileMetrics.rowIconGap),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AuthMetrics.fieldVerticalPadding,
              ),
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: styles.fieldLabel),
                    const SizedBox(height: AuthMetrics.fieldLabelGap),
                    Text(value, style: styles.fieldValue),
                  ],
                ),
              ),
            ),
          ),
          action ??
              Icon(
                Icons.lock_outline,
                size: ProfileMetrics.rowIconSize,
                color: tokens.iconMuted,
              ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        if (help != null)
          Padding(
            padding: EdgeInsets.only(
              top: AuthMetrics.helperGap,
              left: tokens.space2,
            ),
            child: Text(help, style: styles.helper),
          ),
      ],
    );
  }
}
