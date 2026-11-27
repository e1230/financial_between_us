import 'ledger_movement.dart';
import 'pair_ledger.dart';

/// Part of a payment that goes to one pending [item].
final class Allocation {
  const Allocation({required this.item, required this.amount});

  final PendingItem item;

  /// Whole pesos, from 1 to `item.remaining`.
  final int amount;

  /// The payment does not cover the whole item ("abona $ X").
  bool get isPartial => amount < item.remaining;

  PaymentApplication toApplication() =>
      PaymentApplication(targetId: item.id, amount: amount);

  @override
  bool operator ==(Object other) =>
      other is Allocation && other.item.id == item.id && other.amount == amount;

  @override
  int get hashCode => Object.hash(item.id, amount);

  @override
  String toString() => 'Allocation(${item.id}: $amount)';
}

/// Splits a payment of [amount] among [pendings] (oldest first): each item
/// is covered in full before the next one, so only the last one may be
/// partial. With [selectedIds], only those items take part.
///
/// Money beyond the selected items is not allocated (the UI does not allow
/// it; see `MovementValidators.paymentAmount`).
List<Allocation> allocatePayment({
  required int amount,
  required List<PendingItem> pendings,
  Set<String>? selectedIds,
}) {
  final result = <Allocation>[];
  var left = amount;
  for (final item in pendings) {
    if (left <= 0) break;
    if (selectedIds != null && !selectedIds.contains(item.id)) continue;
    final take = left < item.remaining ? left : item.remaining;
    if (take <= 0) continue;
    result.add(Allocation(item: item, amount: take));
    left -= take;
  }
  return result;
}

/// Whole pesos owed by the [pendings] in [selectedIds] (all of them when
/// `null`).
int pendingTotal(List<PendingItem> pendings, [Set<String>? selectedIds]) =>
    pendings
        .where((p) => selectedIds == null || selectedIds.contains(p.id))
        .fold(0, (sum, p) => sum + p.remaining);
