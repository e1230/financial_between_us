import '../../groups/domain/group.dart';
import '../domain/debt.dart';

/// Debts between the members of a group, from which every balance is
/// computed (see `balancesWith`). The UI only depends on this interface.
abstract interface class BalancesRepository {
  /// Live debts of [group]; empty when everybody is even.
  Stream<List<Debt>> watchDebts(Group group);
}

/// Sample debts between the members of a group.
// TODO: replace with a Firestore implementation that derives the debts from
// outings (items split by consumption, tip proportional to it), payments
// and settlements.
// DECISIÓN: until outings exist, each pair of members gets a fixed sample
// (one owes the other, the reverse, or they are even), so the screens show
// the three cases.
class FakeBalancesRepository implements BalancesRepository {
  const FakeBalancesRepository();

  static const List<int> _amounts = [32000, 41500, 18200, 25000, 12800];

  /// Kinds of sample pair, in rotation.
  static const int _patterns = 3;

  @override
  Stream<List<Debt>> watchDebts(Group group) {
    final uids = group.memberUids;
    final debts = <Debt>[];
    var pair = 0;
    for (var i = 0; i < uids.length; i++) {
      for (var j = i + 1; j < uids.length; j++, pair++) {
        final amount = _amounts[pair % _amounts.length];
        switch (pair % _patterns) {
          case 0:
            debts.add(Debt(fromUid: uids[j], toUid: uids[i], amount: amount));
          case 1:
            debts.add(Debt(fromUid: uids[i], toUid: uids[j], amount: amount));
          default:
            break; // Even.
        }
      }
    }
    return Stream.value(debts);
  }
}
