import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../core/theme/app_tokens.dart';
import '../domain/push_message.dart';
import 'notification_content.dart';
import 'notification_strings.dart';

/// Ids of the buttons of a new movement.
abstract final class NotificationActions {
  /// Marks it as seen without opening the app.
  static const String confirm = 'confirm';

  /// Opens the app on the reject dialog.
  static const String reject = 'reject';
}

/// The notifications drawn on the device (`flutter_local_notifications`).
/// Works on the main isolate and on the background ones FCM and the
/// notification actions start.
class LocalNotifications {
  LocalNotifications([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  /// Monochrome status bar icon (`res/drawable/ic_stat_fbu.xml`).
  static const String _icon = 'ic_stat_fbu';

  static const Map<NotificationChannelKind, AndroidNotificationChannel>
  _channels = {
    NotificationChannelKind.movements: AndroidNotificationChannel(
      'movements',
      NotificationStrings.movementsChannel,
      description: NotificationStrings.movementsChannelDescription,
      importance: Importance.high,
    ),
    NotificationChannelKind.groups: AndroidNotificationChannel(
      'groups',
      NotificationStrings.groupsChannel,
      description: NotificationStrings.groupsChannelDescription,
    ),
  };

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Sets the plugin up and creates the channels. [onResponse] gets taps
  /// (and buttons that open the app) while the app runs;
  /// [onBackgroundResponse] gets the buttons that do not, on a background
  /// isolate (a top-level `@pragma('vm:entry-point')` function).
  Future<void> initialize({
    DidReceiveNotificationResponseCallback? onResponse,
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    final android = _android;
    if (android == null) return;
    for (final channel in _channels.values) {
      await android.createNotificationChannel(channel);
    }
  }

  /// Draws [message]; a newer one about the same thing replaces it.
  Future<void> show(PushMessage message) {
    final content = NotificationContent.of(message);
    final channel = _channels[content.channel]!;
    return _plugin.show(
      id: content.id,
      title: content.title,
      body: content.body,
      payload: jsonEncode(message.toData()),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: channel.importance == Importance.high
              ? Priority.high
              : Priority.defaultPriority,
          icon: _icon,
          // The brand green, as the status bar icon tint.
          color: AppTokens.dark.accent,
          styleInformation: BigTextStyleInformation(content.body),
          category: content.channel == NotificationChannelKind.movements
              ? AndroidNotificationCategory.social
              : AndroidNotificationCategory.event,
          actions: content.showsAnswerActions
              ? const [
                  AndroidNotificationAction(
                    NotificationActions.confirm,
                    NotificationStrings.confirm,
                  ),
                  AndroidNotificationAction(
                    NotificationActions.reject,
                    NotificationStrings.reject,
                    showsUserInterface: true,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  /// Removes the notification of the movement [movementId], if any (it
  /// was opened in the app).
  Future<void> cancelMovement(String movementId) =>
      _plugin.cancel(id: notificationIdOf(MovementPush.keyOf(movementId)));

  /// Removes the notification [id] (its button was used).
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  /// The tap that launched the app, if it was launched from a notification.
  Future<NotificationResponse?> launchResponse() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false
        ? details?.notificationResponse
        : null;
  }

  /// Asks for `POST_NOTIFICATIONS` (Android 13+). `true` when allowed.
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  /// The [PushMessage] a [response] belongs to.
  static PushMessage? messageOf(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return null;
    try {
      final data = jsonDecode(payload);
      return data is Map<String, Object?> ? PushMessage.parse(data) : null;
    } on FormatException {
      return null;
    }
  }
}
