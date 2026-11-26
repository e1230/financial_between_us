import 'package:financial_between_us/features/balances/data/balances_repository.dart';
import 'package:financial_between_us/features/balances/domain/debt.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';

/// Fixed debts, the same for every group.
class FixedBalancesRepository implements BalancesRepository {
  FixedBalancesRepository([List<Debt>? debts]) : debts = [...?debts];

  final List<Debt> debts;

  @override
  Stream<List<Debt>> watchDebts(Group group) => Stream.value(debts);
}
