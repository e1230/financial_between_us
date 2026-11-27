import 'package:material_ui/material_ui.dart';

import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../sheets/balances_sheet.dart';
import '../widgets/movement_icon.dart';
import 'quick_movement_kind.dart';

/// "Agregar movimiento": Ingreso, Pago or Deuda. `null` when dismissed.
Future<QuickMovementKind?> showMovementKindSheet(BuildContext context) =>
    showBalancesSheet<QuickMovementKind>(
      context: context,
      builder: (_) => const _MovementKindSheet(),
    );

class _MovementKindSheet extends StatelessWidget {
  const _MovementKindSheet();

  @override
  Widget build(BuildContext context) {
    final styles = BalancesTextStyles.of(context);
    Widget option(
      QuickMovementKind kind,
      MovementIconKind icon,
      String title,
      String text,
    ) => ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 0,
      leading: MovementIcon(icon),
      title: Text(title, style: styles.rowTitle),
      subtitle: Text(text, style: styles.rowDetail),
      onTap: () => Navigator.of(context).pop(kind),
    );
    return BalancesSheetFrame(
      title: BalancesStrings.addMovement,
      children: [
        option(
          QuickMovementKind.income,
          MovementIconKind.received,
          BalancesStrings.income,
          BalancesStrings.incomeText,
        ),
        option(
          QuickMovementKind.payment,
          MovementIconKind.paid,
          BalancesStrings.payment,
          BalancesStrings.paymentText,
        ),
        option(
          QuickMovementKind.debt,
          MovementIconKind.direct,
          BalancesStrings.debt,
          BalancesStrings.debtText,
        ),
      ],
    );
  }
}
