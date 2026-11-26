import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/firestore_providers.dart';
import '../../auth/data/auth_providers.dart';
import '../domain/payment_account.dart';
import 'payment_accounts_repository.dart';

part 'payment_accounts_providers.g.dart';

@Riverpod(keepAlive: true)
PaymentAccountsRepository paymentAccountsRepository(Ref ref) =>
    FirestorePaymentAccountsRepository(ref.watch(firebaseFirestoreProvider));

/// Live payment accounts of the signed-in user, oldest first. Empty when
/// signed out.
@Riverpod(keepAlive: true)
Stream<List<PaymentAccount>> myPaymentAccounts(Ref ref) async* {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* ref.watch(paymentAccountsRepositoryProvider).watch(user.uid);
}

/// The account [accountId] of the signed-in user, or `null` once deleted.
@riverpod
Future<PaymentAccount?> myPaymentAccountById(Ref ref, String accountId) async {
  final accounts = await ref.watch(myPaymentAccountsProvider.future);
  return accounts.where((a) => a.id == accountId).firstOrNull;
}
