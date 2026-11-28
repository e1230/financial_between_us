import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/features/notifications/domain/push_message.dart';
import 'package:financial_between_us/features/notifications/presentation/notification_content.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/notification_fakes.dart';

NotificationContent _content(Map<String, Object?> data) =>
    NotificationContent.of(PushMessage.parse(data)!);

Map<String, Object?> _member(
  String type, {
  String recipient = 'beto',
  String member = 'caro',
}) => {
  'type': type,
  'groupId': 'g1',
  'groupName': 'Viernes',
  'actorUid': 'ana',
  'actorName': 'Ana Ruiz',
  'recipientUid': recipient,
  'memberUid': member,
  'memberName': 'Carolina Díaz',
};

void main() {
  group('a new movement, from the recipient side', () {
    test('a payment to the recipient', () {
      final c = _content(movementData());
      expect(c.title, 'Ana te registró un pago');
      expect(
        c.body,
        '\$ 48.500 · Viernes\n'
        'Ya se aplicó a tu saldo. Si no es correcto, recházalo.',
      );
      expect(c.channel, NotificationChannelKind.movements);
      expect(c.showsAnswerActions, isTrue);
      expect(
        c.route,
        AppRoutes.personBalanceFor('ana', 'g1', movementId: 'm1'),
      );
    });

    test('a payment the recipient made (an "ingreso" of the author)', () {
      final c = _content(
        movementData({'debtorUid': 'beto', 'creditorUid': 'ana'}),
      );
      expect(c.title, 'Ana registró tu pago');
    });

    test('debts in both directions', () {
      final youOwe = _content(
        movementData({
          'movementType': 'debt',
          'debtorUid': 'beto',
          'creditorUid': 'ana',
          'concept': 'Pizza',
        }),
      );
      expect(youOwe.title, 'Ana registró que le debes');
      expect(youOwe.body, startsWith('\$ 48.500 · Pizza · Viernes'));
      final owesYou = _content(
        movementData({'movementType': 'debt', 'concept': 'Pizza'}),
      );
      expect(owesYou.title, 'Ana registró que te debe');
    });
  });

  test('a rejection tells the author why, without buttons', () {
    final c = _content(
      movementData({
        'type': 'movement.rejected',
        'rejectReason': 'not_received',
      }),
    );
    expect(c.title, 'Ana rechazó tu pago');
    expect(c.body, '\$ 48.500 · Viernes · Motivo: No me llegó');
    expect(c.showsAnswerActions, isFalse);
  });

  test('a deletion', () {
    final c = _content(
      movementData({'type': 'movement.deleted', 'movementType': 'debt'}),
    );
    expect(c.title, 'Ana eliminó una deuda');
    expect(c.body, '\$ 48.500 · Viernes · Ya no cuenta en tu saldo');
  });

  test('a new member, directly or approved', () {
    final joined = _content(_member('member.joined'));
    expect(joined.title, 'Nuevo integrante en Viernes');
    expect(joined.body, 'Carolina entró al grupo.');
    expect(joined.channel, NotificationChannelKind.groups);
    expect(joined.route, AppRoutes.groupDetailFor('g1'));

    final others = _content(_member('member.approved'));
    expect(others.body, 'Carolina entró al grupo.');
    final approved = _content(_member('member.approved', recipient: 'caro'));
    expect(approved.title, 'Ya eres parte de Viernes');
    expect(approved.body, 'Ana aprobó tu solicitud.');
  });

  test('a request, a leave and a removal', () {
    expect(
      _content(_member('member.requested')).title,
      'Solicitud para unirse a Viernes',
    );
    expect(_content(_member('member.left')).title, 'Carolina salió de Viernes');

    final removedYou = _content(_member('member.removed', recipient: 'caro'));
    expect(removedYou.title, 'Te eliminaron de Viernes');
    expect(removedYou.route, AppRoutes.home);
    final removed = _content(_member('member.removed'));
    expect(removed.title, 'Carolina ya no está en Viernes');
    expect(removed.body, 'Ana eliminó a Carolina del grupo.');
  });

  test('"Rechazar" leads to rejecting it', () {
    final message = PushMessage.parse(movementData())!;
    final route = Uri.parse(NotificationContent.routeOf(message, reject: true));
    expect(route.path, '/balances/person/ana');
    expect(route.queryParameters, {
      'group': 'g1',
      'movement': 'm1',
      'reject': '1',
    });
  });

  test('notification ids are stable and positive', () {
    expect(notificationIdOf('movement_m1'), notificationIdOf('movement_m1'));
    expect(
      notificationIdOf('movement_m1'),
      isNot(notificationIdOf('movement_m2')),
    );
    expect(notificationIdOf('member_g1_caro'), greaterThanOrEqualTo(0));
    // FNV-1a of "a", masked to 31 bits.
    expect(notificationIdOf('a'), 0xe40c292c & 0x7fffffff);
  });
}
