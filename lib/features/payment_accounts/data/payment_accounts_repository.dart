import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/data/firestore_collections.dart';
import '../../groups/data/group_mapper.dart' show AuditLogFields;
import '../domain/payment_account.dart';
import '../domain/payment_account_failure.dart';
import 'payment_account_mapper.dart';

/// Payment accounts of a user. Every method throws a
/// [PaymentAccountFailure] on error.
abstract interface class PaymentAccountsRepository {
  /// Live accounts of [uid] that are not deleted, oldest first.
  Stream<List<PaymentAccount>> watch(String uid);

  /// Saves a new account of [uid] (its `id` is ignored) and returns its id.
  Future<String> create({required String uid, required PaymentAccount account});

  /// Saves the changes of [account].
  Future<void> update({required String uid, required PaymentAccount account});

  /// Deletes [account] (soft delete: it stays with `deletedAt`).
  Future<void> delete({required String uid, required PaymentAccount account});
}

class FirestorePaymentAccountsRepository implements PaymentAccountsRepository {
  FirestorePaymentAccountsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection(FirestoreCollections.users).doc(uid);

  CollectionReference<Map<String, dynamic>> _accounts(String uid) =>
      _user(uid).collection(FirestoreCollections.paymentAccounts);

  DocumentReference<Map<String, dynamic>> _newAuditEntry(String uid) =>
      _user(uid).collection(FirestoreCollections.userAuditLog).doc();

  @override
  Stream<List<PaymentAccount>> watch(String uid) =>
      _accounts(uid)
          .snapshots()
          .map((snapshot) {
            final accounts = [
              for (final doc in snapshot.docs)
                PaymentAccountMapper.fromFirestore(doc.id, doc.data()),
            ];
            // A just-created account has no `createdAt` until the server
            // answers; `sortAccounts` keeps it last meanwhile.
            // DECISIÓN: filtered and sorted here instead of in the query: a
            // user has a handful of accounts, and `where` + `orderBy` on two
            // fields would need a composite index.
            return sortAccounts([
              for (final a in accounts)
                if (a.deletedAt == null) a,
            ]);
          })
          .handleError((Object error, StackTrace stackTrace) {
            throw _map(error, stackTrace);
          });

  @override
  Future<String> create({
    required String uid,
    required PaymentAccount account,
  }) => _guard(() async {
    final ref = _accounts(uid).doc();
    await (_firestore.batch()
          ..set(ref, PaymentAccountMapper.create(account))
          ..set(
            _newAuditEntry(uid),
            PaymentAccountMapper.auditEntry(
              action: AuditLogFields.actionCreate,
              accountId: ref.id,
              uid: uid,
              after: PaymentAccountMapper.content(account),
            ),
          ))
        .commit();
    return ref.id;
  });

  @override
  Future<void> update({required String uid, required PaymentAccount account}) =>
      _guard(() async {
        final ref = _accounts(uid).doc(account.id);
        await _firestore.runTransaction((tx) async {
          final data = (await tx.get(ref)).data();
          if (data == null) throw const PaymentAccountNotFound();
          final before = PaymentAccountMapper.fromFirestore(ref.id, data);
          if (before.deletedAt != null) throw const PaymentAccountNotFound();
          tx
            ..update(ref, PaymentAccountMapper.update(account))
            ..set(
              _newAuditEntry(uid),
              PaymentAccountMapper.auditEntry(
                action: AuditLogFields.actionUpdate,
                accountId: ref.id,
                uid: uid,
                before: PaymentAccountMapper.content(before),
                after: PaymentAccountMapper.content(account),
              ),
            );
        });
      });

  @override
  Future<void> delete({required String uid, required PaymentAccount account}) =>
      _guard(() async {
        final ref = _accounts(uid).doc(account.id);
        await (_firestore.batch()
              ..update(ref, PaymentAccountMapper.softDelete())
              ..set(
                _newAuditEntry(uid),
                PaymentAccountMapper.auditEntry(
                  action: AuditLogFields.actionDelete,
                  accountId: ref.id,
                  uid: uid,
                  before: PaymentAccountMapper.content(account),
                ),
              ))
            .commit();
      });

  /// Runs [action] and converts any error into a [PaymentAccountFailure].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      throw _map(error, stackTrace);
    }
  }

  static PaymentAccountFailure _map(Object error, StackTrace stackTrace) {
    if (error is PaymentAccountFailure) return error;
    developer.log(
      'Payment account request failed',
      name: 'fbu.paymentAccounts',
      error: error,
      stackTrace: stackTrace,
    );
    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable' ||
        'deadline-exceeded' => const PaymentAccountNetworkFailure(),
        'not-found' => const PaymentAccountNotFound(),
        _ => UnknownPaymentAccountFailure(error.code),
      };
    }
    return const UnknownPaymentAccountFailure();
  }
}

/// [accounts] oldest first (creation order); undated ones go last.
// DECISIÓN: creation order, as the spec suggests.
List<PaymentAccount> sortAccounts(List<PaymentAccount> accounts) {
  final sorted = [...accounts];
  final far = DateTime.utc(9999);
  sorted.sort((a, b) {
    final byDate = (a.createdAt ?? far).compareTo(b.createdAt ?? far);
    return byDate != 0 ? byDate : a.id.compareTo(b.id);
  });
  return sorted;
}
