import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../balances_metrics.dart';
import '../balances_text_styles.dart';
import '../widgets/movement_icon.dart';
import '../widgets/type_chip.dart';
import 'history_entry.dart';

/// A movement of the history: icon, title (with a green dot while new),
/// detail (a clip first when it has an image) and, on the right, the
/// amount over its chip. Rejected ones are dimmed and struck through.
class HistoryRow extends StatelessWidget {
  const HistoryRow({
    super.key,
    required this.entry,
    required this.highlighted,
    required this.onTap,
  });

  final HistoryEntry entry;

  /// Just registered: a `surface` background that fades after 2 s.
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final e = entry;
    final amountColor = switch (e.tone) {
      HistoryAmountTone.normal => tokens.textPrimary,
      HistoryAmountTone.positive => tokens.positive,
      HistoryAmountTone.muted => tokens.textSecondary,
    };

    return Semantics(
      button: true,
      label: e.semanticsLabel,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: reduceMotion
            ? BalancesMetrics.reducedFade
            : BalancesMetrics.settledResize,
        decoration: BoxDecoration(
          color: highlighted
              ? tokens.surface
              : tokens.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(tokens.radiusCard),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: BalancesMetrics.historyRowMinHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: BalancesMetrics.historyRowPaddingV,
              ),
              child: Row(
                children: [
                  Opacity(
                    opacity: e.isRejected ? BalancesMetrics.settledOpacity : 1,
                    child: MovementIcon(e.icon),
                  ),
                  const SizedBox(width: BalancesMetrics.rowGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                e.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.rowTitle,
                              ),
                            ),
                            if (e.isNew) ...[
                              SizedBox(width: tokens.space1),
                              Container(
                                width: BalancesMetrics.newDot,
                                height: BalancesMetrics.newDot,
                                decoration: BoxDecoration(
                                  color: tokens.positive,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (e.hasAttachment) ...[
                              Icon(
                                Icons.attach_file,
                                size: BalancesMetrics.clipIcon,
                                color: tokens.textSecondary,
                              ),
                              const SizedBox(
                                width: BalancesMetrics.chipPaddingV * 2,
                              ),
                            ],
                            Flexible(
                              child: Text(
                                e.detail,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.rowDetail,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: BalancesMetrics.rowGap),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StruckText(
                        text: e.amount,
                        struck: e.isRejected,
                        style: styles.rowTitle.copyWith(color: amountColor),
                      ),
                      const SizedBox(height: BalancesMetrics.chipPaddingV * 2),
                      AnimatedSwitcher(
                        duration: BalancesMetrics.chipSwap,
                        child: TypeChip(e.chip, key: ValueKey(e.chip)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// [text] with a line through it when [struck]; the line grows from left
/// to right (250 ms) when it becomes struck. With
/// `MediaQuery.disableAnimations` it shows at once.
class _StruckText extends StatelessWidget {
  const _StruckText({
    required this.text,
    required this.struck,
    required this.style,
  });

  final String text;
  final bool struck;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final label = Text(text, maxLines: 1, softWrap: false, style: style);
    if (!struck) return label;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
      duration: BalancesMetrics.strike,
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => CustomPaint(
        foregroundPainter: _StrikePainter(
          progress: progress,
          color: style.color ?? context.tokens.textSecondary,
        ),
        child: child,
      ),
      child: label,
    );
  }
}

class _StrikePainter extends CustomPainter {
  const _StrikePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width * progress, y),
      Paint()
        ..color = color
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_StrikePainter old) =>
      old.progress != progress || old.color != color;
}
