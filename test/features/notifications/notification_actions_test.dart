import 'dart:convert';

import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/features/balances/domain/ledger_movement.dart';
import 'package:financial_between_us/features/notifications/domain/push_message.dart';
import 'package:financial_between_us/features/notifications/presentation/background_handlers.dart';
import 'package:financial_between_us/features/notifications/presentation/local_notifications.dart';
import 'package:financial_between_us/features/notifications/presentation/notifications_providers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/movements_fakes.dart';
import '../../support/notification_fakes.dart';

NotificationResponse _response(String? actionId, Map<String, Object?> data) =>
    NotificationResponse(
      notificationResponseType: actionId == null
          ? NotificationResponseType.selectedNotification
          : NotificationResponseType.selectedNotificationAction,
      actionId: actionId,
      payload: jsonEncode(data),
    );

void main() {
  group('routeOfResponse', () {
    test('a tap opens the movement, "Rechazar" opens the rejection', () {
      expect(
        routeOfResponse(_response(null, movementData())),
        AppRoutes.personBalanceFor('ana', 'g1', movementId: 'm1'),
      );
      expect(
        routeOfResponse(_response(NotificationActions.reject, movementData())),
        AppRoutes.personBalanceFor('ana', 'g1', movementId: 'm1', reject: true),
      );
    });

    test('"Confirmar" and unknown payloads open nothing', () {
      expect(
        routeOfResponse(_response(NotificationActions.confirm, movementData())),
        isNull,
      );
      expect(routeOfResponse(_response(null, const {'type': 'x'})), isNull);
      expect(
        routeOfResponse(
          const NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            payload: 'not json',
          ),
        ),
        isNull,
      );
    });
  });

  group('confirmMovement', () {
    LedgerMovement movement() => LedgerMovement(
      id: 'm1',
      groupId: 'g1',
      type: LedgerMovementType.payment,
      debtorUid: 'ana',
      creditorUid: 'beto',
      amount: 48500,
      date: DateTime(2026, 11, 27),
      createdBy: 'ana',
      seenBy: const ['ana'],
    );

    final message = PushMessage.parse(movementData())! as MovementPush;

    test('marks the movement as seen by its recipient', () async {
      final repo = FakeMovementsRepository([movement()]);
      await confirmMovement(repo, message, 'beto');
      expect(repo.calls, ['markSeen:m1']);
      expect(repo.movementsOf('g1').single.seenBy, ['ana', 'beto']);
      expect(repo.movementsOf('g1').single.isActive, isTrue);
    });

    test('does nothing for another account or a missing movement', () async {
      final repo = FakeMovementsRepository([movement()]);
      await confirmMovement(repo, message, 'caro');
      await confirmMovement(repo, message, null);
      await confirmMovement(FakeMovementsRepository(), message, 'beto');
      expect(repo.calls, isEmpty);
    });
  });
}
