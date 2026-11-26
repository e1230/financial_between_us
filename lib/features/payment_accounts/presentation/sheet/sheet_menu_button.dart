import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';

/// The ⋮ of the detail, with "Editar" and "Eliminar" in a 184 dp panel
/// anchored to it. The button keeps a `surfaceVariant` fill while open.
class SheetMenuButton extends StatelessWidget {
  const SheetMenuButton({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);

    Widget item({
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed,
    }) => MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        foregroundColor: color,
        iconColor: color,
        iconSize: PaymentAccountsMetrics.menuIconSize,
        textStyle: styles.menuItem,
        minimumSize: const Size(
          PaymentAccountsMetrics.menuWidth,
          PaymentAccountsMetrics.menuItemHeight,
        ),
        maximumSize: const Size(
          PaymentAccountsMetrics.menuWidth,
          double.infinity,
        ),
        padding: EdgeInsets.symmetric(horizontal: tokens.space2),
      ),
      // MenuItemButton leaves 12 dp between the icon and the label.
      leadingIcon: Icon(icon),
      child: Text(label, style: styles.menuItem.copyWith(color: color)),
    );

    return MenuAnchor(
      alignmentOffset: const Offset(0, PaymentAccountsMetrics.menuPaddingV),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(tokens.surfaceVariant),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        side: WidgetStatePropertyAll(BorderSide(color: tokens.border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusCard),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: PaymentAccountsMetrics.menuPaddingV),
        ),
        minimumSize: const WidgetStatePropertyAll(
          Size(PaymentAccountsMetrics.menuWidth, 0),
        ),
        maximumSize: const WidgetStatePropertyAll(
          Size(PaymentAccountsMetrics.menuWidth, double.infinity),
        ),
      ),
      menuChildren: [
        item(
          icon: Icons.edit_outlined,
          label: PaymentAccountsStrings.edit,
          color: tokens.textPrimary,
          onPressed: onEdit,
        ),
        item(
          icon: Icons.delete_outline,
          label: PaymentAccountsStrings.delete,
          color: tokens.negative,
          onPressed: onDelete,
        ),
      ],
      builder: (context, controller, child) => IconButton(
        tooltip: PaymentAccountsStrings.moreOptions,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        style: IconButton.styleFrom(
          backgroundColor: controller.isOpen
              ? tokens.surfaceVariant
              : tokens.surfaceVariant.withValues(alpha: 0),
          fixedSize: const Size.square(PaymentAccountsMetrics.touchTarget),
        ),
        icon: Icon(Icons.more_vert, color: tokens.textPrimary),
      ),
    );
  }
}
