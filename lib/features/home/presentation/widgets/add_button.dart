import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../balances/presentation/quick/movement_kind_sheet.dart';
import '../../../balances/presentation/quick/quick_movement.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import 'add_popover_menu.dart';

/// The round + of the bottom bar. It opens the "Agregar" popover and turns
/// 45° into an × while it is open. Disabled without an active group.
class AddButton extends StatefulWidget {
  const AddButton({super.key, required this.enabled});

  final bool enabled;

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  bool _open = false;

  Future<void> _toggle(BuildContext anchor) async {
    setState(() => _open = true);
    final choice = await showAddPopover(anchor);
    if (!mounted) return;
    setState(() => _open = false);
    switch (choice) {
      case AddChoice.event:
        await context.push(AppRoutes.newEvent);
      case AddChoice.movement:
        final kind = await showMovementKindSheet(context);
        if (kind != null && mounted) await startQuickMovement(context, kind);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final enabled = widget.enabled;
    return Semantics(
      button: true,
      enabled: enabled,
      expanded: enabled ? _open : null,
      label: _open ? HomeStrings.closeAdd : HomeStrings.add,
      hint: enabled ? null : HomeStrings.unavailable,
      excludeSemantics: true,
      child: Builder(
        builder: (anchor) => GestureDetector(
          onTap: enabled ? () => _toggle(anchor) : null,
          child: Container(
            width: HomeMetrics.addButtonSize,
            height: HomeMetrics.addButtonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tokens.background,
                width: HomeMetrics.addButtonRing,
              ),
              color: enabled ? null : tokens.surfaceVariant,
              gradient: enabled
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [palette.userColor, tokens.glowBright],
                    )
                  : null,
            ),
            child: AnimatedRotation(
              turns: _open ? HomeMetrics.addOpenTurns : 0,
              duration: reduceMotion ? Duration.zero : HomeMetrics.addRotation,
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.add,
                size: HomeMetrics.addIconSize,
                color: enabled ? tokens.onAccent : tokens.textDisabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
