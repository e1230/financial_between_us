import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/relative_date_format.dart';
import '../../domain/movement.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// Icon of each movement type.
IconData movementIcon(MovementType type) => switch (type) {
  MovementType.income => Icons.south_west,
  MovementType.payment => Icons.north_east,
  MovementType.debt || MovementType.owed => Icons.schedule,
};

/// A row of "Últimos movimientos": icon, title, "{place} · {date}", and the
/// amount over a type chip. The amount never wraps.
class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.movement, this.now});

  final Movement movement;

  /// Reference time of the relative date (tests).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = context.userPalette;
    final styles = HomeTextStyles.of(context);
    final m = movement;

    final (accent, background, amountColor, amount, chip) = switch (m.type) {
      MovementType.income => (
        tokens.positive,
        tokens.positive.withValues(alpha: HomeMetrics.semanticTintOpacity),
        tokens.positive,
        MoneyFormat.signed(m.amount),
        HomeStrings.income,
      ),
      MovementType.payment => (
        palette.userSoft,
        palette.userTint,
        tokens.textPrimary,
        MoneyFormat.signed(-m.amount),
        HomeStrings.payment,
      ),
      MovementType.debt => (
        tokens.negative,
        tokens.negative.withValues(alpha: HomeMetrics.semanticTintOpacity),
        tokens.negative,
        MoneyFormat.format(m.amount),
        HomeStrings.debt,
      ),
      MovementType.owed => (
        tokens.positive,
        tokens.positive.withValues(alpha: HomeMetrics.semanticTintOpacity),
        tokens.positive,
        MoneyFormat.format(m.amount),
        HomeStrings.owed,
      ),
    };

    final participants = m.participants;
    final detail = [
      if (m.place.isNotEmpty) m.place,
      RelativeDateFormat.format(m.createdAt, now: now),
      if (m.type == MovementType.payment &&
          participants != null &&
          participants > 1)
        HomeStrings.people(participants),
    ].join(' · ');

    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: HomeMetrics.movementPaddingVertical,
        ),
        child: Row(
          children: [
            Container(
              width: HomeMetrics.movementIconCircle,
              height: HomeMetrics.movementIconCircle,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                movementIcon(m.type),
                size: HomeMetrics.movementIconSize,
                color: accent,
              ),
            ),
            const SizedBox(width: HomeMetrics.movementGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: styles.rowTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    detail,
                    style: styles.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: HomeMetrics.movementGap),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  maxLines: 1,
                  softWrap: false,
                  style: styles.rowAmount.copyWith(color: amountColor),
                ),
                const SizedBox(height: HomeMetrics.legendLineGap),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: HomeMetrics.movementChipPaddingH,
                    vertical: HomeMetrics.movementChipPaddingV,
                  ),
                  decoration: ShapeDecoration(
                    shape: const StadiumBorder(),
                    color: background,
                  ),
                  child: Text(
                    chip,
                    style: styles.badge.copyWith(color: accent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
