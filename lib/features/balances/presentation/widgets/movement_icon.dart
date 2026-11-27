import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../balances_metrics.dart';

/// Kinds of [MovementIcon].
enum MovementIconKind {
  /// Calendar in the user's soft color over their tint.
  event,

  /// Swap arrows in white over `surfaceVariant`.
  direct,

  /// ↙ in green over green at 12 %: a payment the user received.
  received,

  /// ↗ in the user's soft color over their tint: a payment the user made.
  paid,

  /// A credit ("Saldo a favor"), like [direct] with a wallet.
  credit,
}

/// The 40 dp round icon of a pending item or a history row.
class MovementIcon extends StatelessWidget {
  const MovementIcon(this.kind, {super.key});

  final MovementIconKind kind;

  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    final (icon, background, foreground) = switch (kind) {
      MovementIconKind.event => (
        Icons.calendar_today_outlined,
        palette.userTint,
        palette.userSoft,
      ),
      MovementIconKind.direct => (
        Icons.swap_horiz,
        tokens.surfaceVariant,
        tokens.textPrimary,
      ),
      MovementIconKind.received => (
        Icons.south_west,
        tokens.positive.withValues(alpha: BalancesMetrics.semanticTint),
        tokens.positive,
      ),
      MovementIconKind.paid => (
        Icons.north_east,
        palette.userTint,
        palette.userSoft,
      ),
      MovementIconKind.credit => (
        Icons.account_balance_wallet_outlined,
        tokens.surfaceVariant,
        tokens.textPrimary,
      ),
    };
    return ExcludeSemantics(
      child: Container(
        width: BalancesMetrics.avatar,
        height: BalancesMetrics.avatar,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: _iconSize, color: foreground),
      ),
    );
  }
}
