import 'package:material_ui/material_ui.dart';
import 'package:popover/popover.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../../core/widgets/gradient_border_box.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// Options of the "Agregar" popover.
enum AddChoice { event, movement }

/// Opens the "Agregar" popover above [anchor] and returns the chosen
/// option, or `null` if it was dismissed.
// DECISIÓN: popover 0.5 has no border option and its barrier also covers
// the bottom bar; both accepted (allowed by the handoff).
Future<AddChoice?> showAddPopover(BuildContext anchor) {
  final tokens = anchor.tokens;
  final reduceMotion = MediaQuery.disableAnimationsOf(anchor);
  return showPopover<AddChoice>(
    context: anchor,
    direction: PopoverDirection.top,
    width: HomeMetrics.popoverWidth,
    semanticsLabel: HomeStrings.add,
    barrierLabel: MaterialLocalizations.of(anchor).modalBarrierDismissLabel,
    style: PopoverStyle(
      arrowStyle: PopoverArrowStyle.triangle,
      backgroundColor: tokens.surface,
      barrierColor: tokens.brandBackground.withAlpha(
        HomeMetrics.popoverBarrierAlpha,
      ),
      radius: tokens.radiusPanel,
      shadow: const [],
      arrowHeight: HomeMetrics.popoverArrowHeight,
      arrowWidth: HomeMetrics.popoverArrowWidth,
      transition: reduceMotion ? PopoverTransition.other : null,
      transitionDuration: reduceMotion ? HomeMetrics.reducedMotionFade : null,
    ),
    bodyBuilder: (context) => const _AddMenu(),
  );
}

class _AddMenu extends StatelessWidget {
  const _AddMenu();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.all(HomeMetrics.popoverPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _Option(
              icon: Icons.calendar_today_outlined,
              title: HomeStrings.addEvent,
              description: HomeStrings.addEventText,
              choice: AddChoice.event,
            ),
            _Option(
              icon: Icons.swap_horiz,
              title: HomeStrings.addMovement,
              description: HomeStrings.addMovementText,
              choice: AddChoice.movement,
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.description,
    required this.choice,
  });

  final IconData icon;
  final String title;
  final String description;
  final AddChoice choice;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    final styles = HomeTextStyles.of(context);
    return InkWell(
      onTap: () => Navigator.of(context).pop(choice),
      borderRadius: BorderRadius.circular(tokens.radiusCard),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: HomeMetrics.popoverRowMinHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: HomeMetrics.popoverPadding,
            horizontal: HomeMetrics.popoverRowPaddingH,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: HomeMetrics.popoverIconCircle,
                child: GradientBorderBox(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [palette.userColor, tokens.glowBright],
                  ),
                  fill: tokens.surface,
                  child: Icon(
                    icon,
                    size: HomeMetrics.popoverIconSize,
                    color: palette.userSoft,
                  ),
                ),
              ),
              SizedBox(width: tokens.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: styles.rowTitle),
                    Text(description, style: styles.detail),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
