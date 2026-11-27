import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';

/// Kinds of [TypeChip].
enum TypeChipKind {
  /// A debt of an event: user tint and soft color.
  event,

  /// A direct debt: white at 8 %.
  direct,

  /// A payment the user received: green at 12 %.
  paymentIn,

  /// A payment the user made: user tint and soft color.
  paymentOut,

  /// A rejected movement: red at 12 %.
  rejected,

  /// A credit ("Saldo a favor"): white at 8 %.
  credit,
}

/// Pill with the type of a movement: "Evento", "Directo", "Pago",
/// "Rechazado" (Inter 11/16, padding 1 × 8).
class TypeChip extends StatelessWidget {
  const TypeChip(this.kind, {super.key});

  final TypeChipKind kind;

  static String labelOf(TypeChipKind kind) => switch (kind) {
    TypeChipKind.event => BalancesStrings.event,
    TypeChipKind.direct => BalancesStrings.direct,
    TypeChipKind.paymentIn ||
    TypeChipKind.paymentOut => BalancesStrings.payment,
    TypeChipKind.rejected => BalancesStrings.rejected,
    TypeChipKind.credit => BalancesStrings.credit,
  };

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    final styles = BalancesTextStyles.of(context);
    final neutral = tokens.textPrimary.withValues(
      alpha: BalancesMetrics.neutralTint,
    );
    final (background, foreground) = switch (kind) {
      TypeChipKind.event ||
      TypeChipKind.paymentOut => (palette.userTint, palette.userSoft),
      TypeChipKind.direct ||
      TypeChipKind.credit => (neutral, tokens.textPrimary),
      TypeChipKind.paymentIn => (
        tokens.positive.withValues(alpha: BalancesMetrics.semanticTint),
        tokens.positive,
      ),
      TypeChipKind.rejected => (
        tokens.negative.withValues(alpha: BalancesMetrics.semanticTint),
        tokens.negative,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BalancesMetrics.chipPaddingH,
        vertical: BalancesMetrics.chipPaddingV,
      ),
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Text(
        labelOf(kind),
        maxLines: 1,
        softWrap: false,
        style: styles.chip.copyWith(color: foreground),
      ),
    );
  }
}
