import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../home/presentation/home_metrics.dart';
import '../../../home/presentation/home_text_styles.dart';

/// A message with a text action, like an error and "Reintentar".
class GroupsMessage extends StatelessWidget {
  const GroupsMessage({
    super.key,
    required this.text,
    required this.action,
    required this.onAction,
  });

  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = HomeTextStyles.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: styles.cardText),
        SizedBox(height: tokens.space1),
        SizedBox(
          height: HomeMetrics.textButtonHeight,
          child: TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: tokens.positive),
            child: Text(action, style: styles.link),
          ),
        ),
      ],
    );
  }
}
