import 'pair_ledger.dart';

/// The user's ledger with one person in a scope, and the groups it covers.
final class PersonLedger {
  const PersonLedger({required this.ledger, required this.groupIds});

  /// Pending items and history of every group of [groupIds] together.
  final PairLedger ledger;

  /// Groups of the scope that the person shares with the user (or where
  /// they have movements together).
  final List<String> groupIds;
}
