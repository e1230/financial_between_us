import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/notifications/domain/push_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/notification_fakes.dart';

void main() {
  test('parses a movement and keeps its data', () {
    final message = PushMessage.parse(movementData());
    expect(message, isA<MovementPush>());
    final m = message! as MovementPush;
    expect(m.kind, MovementPushKind.created);
    expect(m.movementType, LedgerMovementType.payment);
    expect(m.amount, 48500);
    expect(m.actorIsDebtor, isTrue);
    expect(m.canAnswer, isTrue);
    expect(m.key, 'movement_m1');
    expect(PushMessage.parse(m.toData())?.toData(), m.toData());
  });

  test('parses the reason of a rejection', () {
    final m =
        PushMessage.parse(
              movementData({
                'type': 'movement.rejected',
                'rejectReason': 'wrong_amount',
              }),
            )!
            as MovementPush;
    expect(m.rejectReason, RejectReason.wrongAmount);
    expect(m.canAnswer, isFalse);
  });

  test('parses a member event', () {
    final m =
        PushMessage.parse({
              'type': 'member.removed',
              'groupId': 'g1',
              'groupName': 'Viernes',
              'actorUid': 'ana',
              'actorName': 'Ana',
              'recipientUid': 'caro',
              'memberUid': 'caro',
              'memberName': 'Carolina',
            })!
            as MemberPush;
    expect(m.kind, MemberPushKind.removed);
    expect(m.isAboutRecipient, isTrue);
    expect(m.key, 'member_g1_caro');
  });

  test('ignores data that is not a valid notification', () {
    expect(PushMessage.parse(const {}), isNull);
    expect(PushMessage.parse(movementData({'type': 'event.created'})), isNull);
    expect(PushMessage.parse(movementData({'recipientUid': ''})), isNull);
    expect(PushMessage.parse(movementData({'amount': '12.5'})), isNull);
    expect(PushMessage.parse(movementData({'movementType': 'gift'})), isNull);
    expect(
      PushMessage.parse({
        ...movementData(),
        'type': 'member.joined',
        'memberUid': null,
      }),
      isNull,
    );
  });
}
