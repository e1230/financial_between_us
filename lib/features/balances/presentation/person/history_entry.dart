import '../../../../core/utils/money_format.dart';
import '../../domain/ledger_movement.dart';
import '../../domain/pair_ledger.dart';
import '../balances_format.dart';
import '../balances_strings.dart';
import '../widgets/movement_icon.dart';
import '../widgets/type_chip.dart';

/// Tone of the amount of a history row.
enum HistoryAmountTone {
  /// `textPrimary`: a debt or a payment the user made.
  normal,

  /// Green: a payment the user received.
  positive,

  /// 60 %: a settled debt, or a rejected movement (also struck through).
  muted,
}

/// How a movement shows up in the history of a person (see the table of
/// section 3 of the spec).
final class HistoryEntry {
  const HistoryEntry({
    required this.movement,
    required this.icon,
    required this.title,
    required this.detail,
    required this.amount,
    required this.tone,
    required this.chip,
    required this.isNew,
  });

  /// Describes [m] for [me], whose counterpart's first name is
  /// [otherFirst]. [ledger] tells which debts are settled and [related]
  /// gives the debts a payment applied to.
  factory HistoryEntry.of(
    LedgerMovement m, {
    required String me,
    required String otherFirst,
    required PairLedger ledger,
    required Map<String, LedgerMovement> related,
    DateTime? now,
  }) {
    final date = BalancesDates.short(m.date, now: now);
    final received = m.isPayment && m.creditorUid == me;

    // Icon, title and the chip of an active movement.
    final MovementIconKind icon;
    final String title;
    final TypeChipKind chip;
    if (m.isDebt) {
      final isEvent = m.kind == DebtKind.event;
      icon = isEvent ? MovementIconKind.event : MovementIconKind.direct;
      title = m.eventName ?? m.concept;
      chip = isEvent ? TypeChipKind.event : TypeChipKind.direct;
    } else {
      icon = received ? MovementIconKind.received : MovementIconKind.paid;
      final target = m.appliedTo.isEmpty
          ? null
          : related[m.appliedTo.first.targetId];
      final partial =
          target != null && m.appliedTo.first.amount < target.amount;
      title = received
          ? partial
                ? BalancesStrings.partialPaidYou(otherFirst)
                : BalancesStrings.paidYou(otherFirst)
          : BalancesStrings.youPaid;
      chip = received ? TypeChipKind.paymentIn : TypeChipKind.paymentOut;
    }

    final settled =
        m.isActive && m.isDebt && !ledger.pendings.any((p) => p.id == m.id);

    final String detail;
    if (m.isRejected) {
      final when = BalancesDates.relative(m.rejectedAt ?? m.date, now: now);
      detail = m.rejectedBy == me
          ? BalancesStrings.rejectedByYou(when)
          : BalancesStrings.rejectedBy(otherFirst, when);
    } else if (settled) {
      detail =
          '$date · ${ledger.offsetIds.contains(m.id) ? BalancesStrings.offsetDebt : BalancesStrings.settledDebt}';
    } else if (m.isDebt) {
      final String who;
      if (m.kind == DebtKind.event) {
        who = m.creditorUid == me
            ? BalancesStrings.youPaidBill
            : BalancesStrings.paidBill(otherFirst);
      } else {
        who = m.createdBy == me
            ? BalancesStrings.registeredByYou
            : BalancesStrings.registeredBy(otherFirst);
      }
      detail = '$date · $who';
    } else {
      final target = m.appliedTo.isEmpty
          ? null
          : related[m.appliedTo.first.targetId];
      detail = [
        if (target != null)
          BalancesStrings.appliedTo(target.eventName ?? target.concept),
        date,
        ?m.account?.name,
      ].join(' · ');
    }

    final String amount;
    if (m.isPayment) {
      amount = received
          ? MoneyFormat.signed(m.amount)
          : MoneyFormat.signed(-m.amount);
    } else {
      amount = MoneyFormat.format(m.amount);
    }

    return HistoryEntry(
      movement: m,
      icon: icon,
      title: title,
      detail: detail,
      amount: amount,
      tone: m.isRejected || settled
          ? HistoryAmountTone.muted
          : received
          ? HistoryAmountTone.positive
          : HistoryAmountTone.normal,
      chip: m.isRejected ? TypeChipKind.rejected : chip,
      isNew: m.isNewFor(me),
    );
  }

  final LedgerMovement movement;
  final MovementIconKind icon;
  final String title;
  final String detail;
  final String amount;
  final HistoryAmountTone tone;
  final TypeChipKind chip;

  /// Registered by the other person and not opened yet.
  final bool isNew;

  bool get isRejected => movement.isRejected;
  bool get hasAttachment => movement.attachment != null;

  /// What screen readers say.
  String get semanticsLabel => [
    title,
    TypeChip.labelOf(chip),
    detail,
    amount,
    if (hasAttachment) BalancesStrings.attachment,
    if (isRejected) BalancesStrings.rejectedState,
    if (isNew) BalancesStrings.newDot,
  ].join(', ');
}

/// History filters.
enum HistoryFilter {
  all,
  events,
  direct,
  payments;

  bool accepts(LedgerMovement m) => switch (this) {
    HistoryFilter.all => true,
    HistoryFilter.events => m.isDebt && m.kind == DebtKind.event,
    HistoryFilter.direct => m.isDebt && m.kind == DebtKind.direct,
    HistoryFilter.payments => m.isPayment,
  };

  String get label => switch (this) {
    HistoryFilter.all => BalancesStrings.filterAll,
    HistoryFilter.events => BalancesStrings.filterEvents,
    HistoryFilter.direct => BalancesStrings.filterDirect,
    HistoryFilter.payments => BalancesStrings.filterPayments,
  };
}
