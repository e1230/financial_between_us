import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../notifications/presentation/notifications_providers.dart';
import '../../../payment_accounts/presentation/widgets/payment_account_logo.dart';
import '../../data/balances_providers.dart';
import '../../domain/ledger_movement.dart';
import '../attachment_viewer_screen.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/type_chip.dart';
import 'balances_sheet.dart';
import 'delete_movement_dialog.dart';
import 'detail_parts.dart';
import 'reject_dialog.dart';

/// What happened in the movement detail.
enum MovementSheetOutcome { rejected, deleted }

/// Opens the detail of [movement] between [me] and the other person. It is
/// marked as seen. [related] gives the debts a payment settled. With
/// [openReject] (the "Rechazar" of a notification) the reject dialog opens
/// right away, if it can still be rejected.
Future<MovementSheetOutcome?> showMovementDetailSheet(
  BuildContext context, {
  required LedgerMovement movement,
  required String me,
  required String otherFirstName,
  required Map<String, LedgerMovement> related,
  bool openReject = false,
}) => showBalancesSheet<MovementSheetOutcome>(
  context: context,
  builder: (_) => MovementDetailSheet(
    movement: movement,
    me: me,
    otherFirstName: otherFirstName,
    related: related,
    openReject: openReject,
  ),
);

/// A movement, read-only: who registered it and when, the amount (green
/// when it favors the user), what it applied to, the account, the note, the
/// image and, when allowed, "Rechazar" (its recipient) or "Eliminar" (its
/// author). Nobody edits a movement.
class MovementDetailSheet extends ConsumerStatefulWidget {
  const MovementDetailSheet({
    super.key,
    required this.movement,
    required this.me,
    required this.otherFirstName,
    required this.related,
    this.openReject = false,
  });

  final LedgerMovement movement;
  final String me;
  final String otherFirstName;
  final Map<String, LedgerMovement> related;
  final bool openReject;

  @override
  ConsumerState<MovementDetailSheet> createState() =>
      _MovementDetailSheetState();
}

class _MovementDetailSheetState extends ConsumerState<MovementDetailSheet> {
  @override
  void initState() {
    super.initState();
    final m = widget.movement;
    if (m.isNewFor(widget.me)) {
      // Opening it clears the "new" dot; a failure only keeps the dot.
      ref
          .read(movementActionsProvider)
          .markSeen(movement: m, me: widget.me)
          .ignore();
    }
    // Its notification, if still there, is answered by opening it.
    ref.read(localNotificationsProvider).cancelMovement(m.id).ignore();
    if (widget.openReject && m.canReject(widget.me)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reject();
      });
    }
  }

  Future<void> _reject() async {
    final rejected = await showRejectDialog(
      context,
      movement: widget.movement,
      me: widget.me,
      otherFirstName: widget.otherFirstName,
    );
    if (rejected && mounted) {
      Navigator.of(context).pop(MovementSheetOutcome.rejected);
    }
  }

  Future<void> _delete() async {
    final deleted = await showDeleteMovementDialog(
      context,
      movement: widget.movement,
      me: widget.me,
    );
    if (deleted && mounted) {
      Navigator.of(context).pop(MovementSheetOutcome.deleted);
    }
  }

  String _title() {
    final m = widget.movement;
    final first = widget.otherFirstName;
    if (m.createdBy == widget.me) {
      return m.isPayment
          ? BalancesStrings.youRegisteredPayment
          : BalancesStrings.youRegisteredDebt;
    }
    return m.isPayment
        ? BalancesStrings.theyRegisteredPayment(first)
        : BalancesStrings.theyRegisteredDebt(first);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final m = widget.movement;
    final me = widget.me;
    final first = widget.otherFirstName;
    final favorsMe = m.creditorUid == me;
    final when = BalancesDates.withTime(m.createdAt ?? m.date);
    final subtitle = m.isRejected
        ? BalancesStrings.rejectedOn(when)
        : BalancesStrings.appliedNow(when);
    final amountStyle = styles.balanceAmount.copyWith(
      color: m.isRejected
          ? tokens.textSecondary
          : favorsMe
          ? tokens.positive
          : tokens.negative,
      decoration: m.isRejected ? TextDecoration.lineThrough : null,
      decorationColor: tokens.textSecondary,
    );

    final rows = <Widget>[];
    void row(String label, Widget value) =>
        rows.add(DetailRow(label: label, value: value));
    Text valueText(String text) => Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: styles.rowTitle,
    );

    if (m.isPayment) {
      final targets = [
        for (final a in m.appliedTo) ?widget.related[a.targetId],
      ];
      if (targets.isNotEmpty) {
        final firstTarget = targets.first;
        final name = firstTarget.eventName ?? firstTarget.concept;
        row(
          BalancesStrings.appliedToLabel,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: valueText(
                  targets.length > 1 ? '$name +${targets.length - 1}' : name,
                ),
              ),
              SizedBox(width: tokens.space1),
              TypeChip(
                firstTarget.kind == DebtKind.event
                    ? TypeChipKind.event
                    : TypeChipKind.direct,
              ),
            ],
          ),
        );
      }
      if (m.account case final account?) {
        row(
          m.createdBy != me && favorsMe
              ? BalancesStrings.saysPaidTo
              : BalancesStrings.paidTo,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PaymentAccountLogo(type: account.type),
              SizedBox(width: tokens.space1),
              Flexible(child: valueText(account.name)),
            ],
          ),
        );
      }
    } else {
      if (m.eventName case final event?) {
        row(BalancesStrings.eventLabel, valueText(event));
      }
      if (m.concept.isNotEmpty) {
        row(BalancesStrings.concepto, valueText(m.concept));
      }
    }
    if (m.note case final note? when note.isNotEmpty) {
      row(BalancesStrings.note, valueText(note));
    }
    if (m.isRejected) {
      final reason = m.rejectReason;
      final note = m.rejectNote;
      row(
        BalancesStrings.reason,
        valueText(
          [
            if (reason != null) rejectReasonLabel(reason),
            if (note != null && note.isNotEmpty) note,
          ].join(' · '),
        ),
      );
    }

    final attachment = m.attachment;
    final canReject = m.canReject(me);
    final canDelete = m.canDelete(me);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final tag = attachmentTag(m.id);

    final gotIt = FbuPrimaryButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text(BalancesStrings.gotIt),
    );
    final Widget footer;
    if (canReject || canDelete) {
      footer = Row(
        children: [
          Expanded(
            child: DangerButton(
              label: canReject
                  ? BalancesStrings.reject
                  : BalancesStrings.delete,
              icon: canReject ? Icons.undo : Icons.delete_outline,
              onPressed: canReject ? _reject : _delete,
            ),
          ),
          const SizedBox(width: BalancesMetrics.actionBarGap),
          Expanded(child: gotIt),
        ],
      );
    } else {
      footer = gotIt;
    }

    return BalancesSheetFrame(
      title: _title(),
      subtitle: subtitle,
      footer: footer,
      children: [
        Semantics(
          label: m.isRejected
              ? '${MoneyFormat.format(m.amount)}, ${BalancesStrings.rejectedState}'
              : null,
          child: ExcludeSemantics(
            excluding: m.isRejected,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                MoneyFormat.format(m.amount),
                maxLines: 1,
                softWrap: false,
                style: amountStyle,
              ),
            ),
          ),
        ),
        if (rows.isNotEmpty) ...[
          SizedBox(height: tokens.space2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: tokens.space2),
            decoration: BoxDecoration(
              color: tokens.background,
              borderRadius: BorderRadius.circular(tokens.radiusCard),
            ),
            child: Column(children: rows),
          ),
        ],
        if (attachment != null) ...[
          SizedBox(height: tokens.space3),
          Text(BalancesStrings.attachmentSection, style: styles.sectionLabel),
          SizedBox(height: tokens.space1),
          Semantics(
            button: true,
            label: BalancesStrings.attachmentLabel,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => context.push(
                AppRoutes.attachment,
                extra: AttachmentViewerArgs.network(
                  url: attachment.url,
                  heroTag: tag,
                ),
              ),
              child: HeroMode(
                enabled: !reduceMotion,
                child: Hero(
                  tag: tag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusCard),
                    child: Image.network(
                      attachment.url,
                      height: BalancesMetrics.thumbnailHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, _) => Container(
                        height: BalancesMetrics.thumbnailHeight,
                        color: tokens.surfaceVariant,
                        alignment: Alignment.center,
                        child: Text(
                          BalancesStrings.imageUnavailable,
                          style: styles.body,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (canReject) ...[
          SizedBox(height: tokens.space2),
          SheetNotice(
            m.isPayment && favorsMe
                ? BalancesStrings.rejectHintPayment(first, m.amount)
                : BalancesStrings.rejectHintDebt(first),
          ),
        ],
      ],
    );
  }
}
