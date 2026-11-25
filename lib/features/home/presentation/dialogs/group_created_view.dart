import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../groups/domain/group_code_lookup.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';
import 'code_box.dart';
import 'dialog_parts.dart';

/// "Grupo creado": the code to share (with copy) and "Listo".
class GroupCreatedView extends StatelessWidget {
  const GroupCreatedView({
    super.key,
    required this.group,
    required this.onDone,
  });

  final CreatedGroup group;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DialogBadge(
          icon: Icons.check,
          color: tokens.positive,
          background: tokens.positive.withValues(
            alpha: HomeMetrics.semanticTintOpacity,
          ),
        ),
        SizedBox(height: tokens.space3),
        DialogHeading(
          title: HomeStrings.createdTitle,
          subtitle: HomeStrings.createdText(group.name),
        ),
        SizedBox(height: tokens.space3),
        CodeBox(code: group.code),
        if (group.hasPassword) ...[
          SizedBox(height: tokens.space1),
          Text(
            HomeStrings.alsoPassword,
            style: HomeTextStyles.of(context).small,
          ),
        ],
        SizedBox(height: tokens.space3),
        FbuPrimaryButton(
          onPressed: onDone,
          child: const Text(HomeStrings.done),
        ),
      ],
    );
  }
}
