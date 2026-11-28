import 'package:financial_between_us/features/notifications/data/notification_dispatcher.dart';
import 'package:financial_between_us/features/notifications/domain/push_event.dart';

/// Records the events instead of calling the Worker.
class FakeNotificationDispatcher implements NotificationDispatcher {
  final List<PushEvent> events = [];

  /// The events as their JSON bodies, easy to compare.
  List<Map<String, Object>> get bodies => [for (final e in events) e.toJson()];

  @override
  Future<void> notify(PushEvent event) async => events.add(event);
}

/// FCM data of a new payment from `ana` to `beto` in `g1`; [changes]
/// override fields.
Map<String, Object?> movementData([Map<String, Object?> changes = const {}]) =>
    {
      'type': 'movement.created',
      'groupId': 'g1',
      'groupName': 'Viernes',
      'actorUid': 'ana',
      'actorName': 'Ana Ruiz',
      'recipientUid': 'beto',
      'movementId': 'm1',
      'movementType': 'payment',
      'debtorUid': 'ana',
      'creditorUid': 'beto',
      'amount': '48500',
      'concept': '',
      ...changes,
    };
