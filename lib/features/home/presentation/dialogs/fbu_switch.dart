import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';

/// The app's on/off switch: off, a dark track with a grey border and a
/// small grey thumb; on, a green track with a big dark thumb (150 ms).
///
/// It only paints; the row around it handles taps and semantics.
class FbuSwitch extends StatelessWidget {
  const FbuSwitch({super.key, required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : tokens.motionFast;
    final thumb = value
        ? HomeMetrics.switchThumbOn
        : HomeMetrics.switchThumbOff;
    return AnimatedContainer(
      duration: duration,
      width: HomeMetrics.switchWidth,
      height: HomeMetrics.switchHeight,
      padding: const EdgeInsets.symmetric(horizontal: HomeMetrics.switchBorder),
      decoration: ShapeDecoration(
        color: value ? tokens.positive : tokens.surfaceVariant,
        shape: StadiumBorder(
          side: BorderSide(
            width: HomeMetrics.switchBorder,
            color: value ? tokens.positive : tokens.switchOffBorder,
          ),
        ),
      ),
      child: AnimatedAlign(
        duration: duration,
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: AnimatedContainer(
          duration: duration,
          width: thumb,
          height: thumb,
          margin: EdgeInsets.symmetric(
            horizontal:
                (HomeMetrics.switchHeight - thumb) / 2 -
                HomeMetrics.switchBorder,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? tokens.onAccent : tokens.iconMuted,
          ),
        ),
      ),
    );
  }
}
