import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_between_us/features/balances/data/movement_mapper.dart';
import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/payment_accounts/domain/payment_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final date = DateTime(2026, 11, 24, 18, 30);
  final payment = LedgerMovement(
    id: 'p1',
    groupId: 'g1',
    type: LedgerMovementType.payment,
    debtorUid: 'santi',
    creditorUid: 'me',
    amount: 10000,
    appliedTo: const [PaymentApplication(targetId: 'bolos', amount: 10000)],
    account: const AccountSnapshot(
      type: PaymentAccountType.nequi,
      name: 'Nequi personal',
      reference: '3001234567',
    ),
    attachment: const MovementAttachment(
      url: 'https://res.cloudinary.com/x.jpg',
      width: 1200,
      height: 1600,
      bytes: 240000,
    ),
    date: date,
    createdBy: 'santi',
  );

  test('a created payment reads back the same', () {
    final data = MovementMapper.create(payment)
      ..[MovementFields.createdAt] = Timestamp.fromDate(date);
    final read = MovementMapper.fromFirestore('g1', 'p1', data);
    expect(read, payment.copyWith(createdAt: date, seenBy: ['santi']));
    expect(data[MovementFields.participants], ['santi', 'me']);
    expect(data[MovementFields.status], 'active');
    expect(data.containsKey(MovementFields.kind), isFalse);
  });

  test('a debt stores its kind and event and no applications', () {
    final debt = LedgerMovement(
      id: 'd1',
      groupId: 'g1',
      type: LedgerMovementType.debt,
      debtorUid: 'santi',
      creditorUid: 'me',
      amount: 41000,
      kind: DebtKind.event,
      eventId: 'e1',
      eventName: 'Andrés Carne de Res',
      concept: ' Cena ',
      date: date,
      createdBy: 'me',
    );
    final data = MovementMapper.create(debt);
    expect(data[MovementFields.kind], 'event');
    expect(data[MovementFields.eventName], 'Andrés Carne de Res');
    expect(data[MovementFields.concept], 'Cena');
    expect(data.containsKey(MovementFields.appliedTo), isFalse);
  });

  test('invalid documents are skipped', () {
    Map<String, dynamic> base() => {
      MovementFields.type: 'debt',
      MovementFields.debtorUid: 'a',
      MovementFields.creditorUid: 'b',
      MovementFields.amount: 1000,
      MovementFields.date: Timestamp.fromDate(date),
    };
    expect(MovementMapper.fromFirestore('g', 'x', base()), isNotNull);
    expect(
      MovementMapper.fromFirestore(
        'g',
        'x',
        base()..[MovementFields.type] = 'gift',
      ),
      isNull,
    );
    expect(
      MovementMapper.fromFirestore(
        'g',
        'x',
        base()..[MovementFields.amount] = 0,
      ),
      isNull,
    );
    expect(
      MovementMapper.fromFirestore(
        'g',
        'x',
        base()..[MovementFields.amount] = 1.5,
      ),
      isNull,
    );
    expect(
      MovementMapper.fromFirestore(
        'g',
        'x',
        base()..remove(MovementFields.date),
      ),
      isNull,
    );
  });

  test('an unknown status never counts as active', () {
    final read = MovementMapper.fromFirestore('g', 'x', {
      MovementFields.type: 'debt',
      MovementFields.debtorUid: 'a',
      MovementFields.creditorUid: 'b',
      MovementFields.amount: 1000,
      MovementFields.date: Timestamp.fromDate(date),
      MovementFields.status: 'archived',
    });
    expect(read!.isActive, isFalse);
  });

  test('reject writes the reason and marks it seen', () {
    final data = MovementMapper.reject(
      uid: 'me',
      reason: RejectReason.notReceived,
    );
    expect(data[MovementFields.status], 'rejected');
    expect(data[MovementFields.rejectReason], 'not_received');
    expect(data[MovementFields.rejectedBy], 'me');
  });

  group('permissions', () {
    test('only the recipient rejects; only the author deletes', () {
      expect(payment.canReject('me'), isTrue);
      expect(payment.canReject('santi'), isFalse);
      expect(payment.canReject('juli'), isFalse);
      expect(payment.canDelete('santi'), isTrue);
      expect(payment.canDelete('me'), isFalse);
      final rejected = payment.copyWith(status: MovementStatus.rejected);
      expect(rejected.canReject('me'), isFalse);
      expect(rejected.canDelete('santi'), isFalse);
    });
  });
}
