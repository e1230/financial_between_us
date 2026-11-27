import 'package:material_ui/material_ui.dart';

import '../balances_metrics.dart';
import '../balances_text_styles.dart';

/// "TE DEBEN · 3": the label above a card, with an optional [trailing]
/// action ("Ver todo").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final styles = BalancesTextStyles.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: BalancesMetrics.sectionLabelPaddingH,
        bottom: BalancesMetrics.sectionLabelBottomGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text, style: styles.sectionLabel),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
