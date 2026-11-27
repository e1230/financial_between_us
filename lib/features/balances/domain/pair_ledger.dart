import 'ledger_movement.dart';

/// Kind of a [PendingItem].
enum PendingKind {
  /// Unpaid (part of) a debt of an event.
  event,

  /// Unpaid (part of) a direct debt.
  direct,

  /// "Saldo a favor": money a payer handed over that no longer settles any
  /// debt (the debt was rejected or deleted, or the payment exceeded it).
  /// The receiver now owes it back.
  credit,
}

/// Something one party still owes the other.
final class PendingItem {
  const PendingItem({
    required this.id,
    required this.groupId,
    required this.kind,
    required this.debtorUid,
    required this.creditorUid,
    required this.title,
    required this.date,
    required this.original,
    required this.remaining,
    required this.source,
  });

  /// The debt id, or [creditIdFor] the payment that produced a credit.
  final String id;
  final String groupId;
  final PendingKind kind;
  final String debtorUid;
  final String creditorUid;

  /// Concept or event name of the debt; empty for a credit.
  final String title;
  final DateTime date;

  /// Whole pesos owed at first.
  final int original;

  /// Whole pesos still owed (> 0).
  final int remaining;

  /// The debt, or the payment that produced the credit.
  final LedgerMovement source;

  /// Whole pesos already paid.
  int get paid => original - remaining;

  /// Whether a payment covered part of it ("abonó").
  bool get isPartiallyPaid => paid > 0;

  /// Share already paid, from 0 to 1.
  double get paidFraction => original == 0 ? 0 : paid / original;

  /// Id of the credit produced by the payment [paymentId].
  static String creditIdFor(String paymentId) => 'credit:$paymentId';

  PendingItem _withRemaining(int value) => PendingItem(
    id: id,
    groupId: groupId,
    kind: kind,
    debtorUid: debtorUid,
    creditorUid: creditorUid,
    title: title,
    date: date,
    original: original,
    remaining: value,
    source: source,
  );

  @override
  String toString() => 'PendingItem($id: $remaining of $original)';
}

/// Money between [me] and [other]: what is pending in each direction, the
/// balance and the history.
///
/// Computed from the movements on every change (balances are never
/// stored):
/// 1. Each active debt starts owing its full amount.
/// 2. Active payments, in chronological order, settle the items of their
///    `appliedTo`.
/// 3. What a payment could not settle that way (its target is no longer
///    active, or it was already paid) goes to the oldest pending items in
///    the same direction.
/// 4. Whatever is still left becomes a credit the receiver owes the payer.
// DECISIÓN: an orphan payment (its debt was rejected or deleted) first
// settles the payer's other pending items, oldest first; only what remains
// shows up as "Saldo a favor", a pending item in the opposite direction.
final class PairLedger {
  const PairLedger({
    required this.me,
    required this.other,
    required this.pendings,
    required this.history,
  });

  /// Ledger of [me] with [other] from the [movements] of one group (others
  /// are ignored).
  factory PairLedger.compute({
    required String me,
    required String other,
    required Iterable<LedgerMovement> movements,
  }) {
    final mine = [
      for (final m in movements)
        if (m.involves(me) && m.involves(other) && me != other) m,
    ]..sort(compareChronologically);

    // Open items in chronological order; updated in place.
    final open = <PendingItem>[];
    int indexOf(String id) => open.indexWhere((p) => p.id == id);

    for (final debt in mine.where((m) => m.isActive && m.isDebt)) {
      open.add(
        PendingItem(
          id: debt.id,
          groupId: debt.groupId,
          kind: debt.kind == DebtKind.event
              ? PendingKind.event
              : PendingKind.direct,
          debtorUid: debt.debtorUid,
          creditorUid: debt.creditorUid,
          title: debt.eventName ?? debt.concept,
          date: debt.date,
          original: debt.amount,
          remaining: debt.amount,
          source: debt,
        ),
      );
    }

    /// Takes up to [amount] from the item at [i]; returns what was taken.
    int settle(int i, int amount) {
      final item = open[i];
      final take = amount < item.remaining ? amount : item.remaining;
      open[i] = item._withRemaining(item.remaining - take);
      return take;
    }

    bool sameDirection(PendingItem item, LedgerMovement payment) =>
        item.debtorUid == payment.debtorUid &&
        item.creditorUid == payment.creditorUid;

    for (final payment in mine.where((m) => m.isActive && m.isPayment)) {
      var leftover = payment.amount - payment.appliedTotal;
      if (leftover < 0) leftover = 0;
      for (final application in payment.appliedTo) {
        final i = indexOf(application.targetId);
        if (i >= 0 && sameDirection(open[i], payment)) {
          leftover += application.amount - settle(i, application.amount);
        } else {
          leftover += application.amount;
        }
      }
      for (var i = 0; i < open.length && leftover > 0; i++) {
        if (sameDirection(open[i], payment) && open[i].remaining > 0) {
          leftover -= settle(i, leftover);
        }
      }
      if (leftover > 0) {
        open.add(
          PendingItem(
            id: PendingItem.creditIdFor(payment.id),
            groupId: payment.groupId,
            kind: PendingKind.credit,
            debtorUid: payment.creditorUid,
            creditorUid: payment.debtorUid,
            title: '',
            date: payment.date,
            original: leftover,
            remaining: leftover,
            source: payment,
          ),
        );
      }
    }

    final pendings = [
      for (final item in open)
        if (item.remaining > 0) item,
    ]..sort(_byDate);

    return PairLedger(
      me: me,
      other: other,
      pendings: pendings,
      history: _newestFirst(mine.where((m) => !m.isDeleted)),
    );
  }

  /// One ledger for the same pair across several groups.
  factory PairLedger.merge({
    required String me,
    required String other,
    required Iterable<PairLedger> ledgers,
  }) {
    final list = ledgers.toList();
    return PairLedger(
      me: me,
      other: other,
      pendings: [for (final l in list) ...l.pendings]..sort(_byDate),
      history: _newestFirst([for (final l in list) ...l.history]),
    );
  }

  final String me;
  final String other;

  /// What is still owed in either direction, oldest first.
  final List<PendingItem> pendings;

  /// Active and rejected movements (deleted ones are hidden), newest first.
  final List<LedgerMovement> history;

  /// Whole pesos: positive when [other] owes [me] ("Te debe"), negative
  /// when [me] owes [other] ("Le debes"), zero when even.
  int get balance => pendings.fold(
    0,
    (sum, p) => p.creditorUid == me ? sum + p.remaining : sum - p.remaining,
  );

  /// Pending items that [payerUid] owes, oldest first: what a payment of
  /// theirs can settle.
  List<PendingItem> pendingsOwedBy(String payerUid) => [
    for (final p in pendings)
      if (p.debtorUid == payerUid) p,
  ];

  /// Date of the most recent movement, or `null` without movements.
  DateTime? get lastActivityAt => history.isEmpty ? null : history.first.date;

  /// Movements [other] registered that [me] has not opened.
  int get newCount => history.where((m) => m.isNewFor(me)).length;

  /// Oldest pending item, or `null` when there are none.
  DateTime? get oldestPendingAt =>
      pendings.isEmpty ? null : pendings.first.date;

  static int _byDate(PendingItem a, PendingItem b) {
    final byDate = a.date.compareTo(b.date);
    return byDate != 0 ? byDate : compareChronologically(a.source, b.source);
  }

  static List<LedgerMovement> _newestFirst(Iterable<LedgerMovement> items) =>
      items.toList()..sort((a, b) => compareChronologically(b, a));
}
