import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/startup/app_startup.dart';
import '../../auth/data/auth_providers.dart';
import '../data/notifications_data_providers.dart';
import '../domain/push_message.dart';
import 'background_handlers.dart';
import 'local_notifications.dart';
import 'notification_content.dart';

part 'notifications_providers.g.dart';

@Riverpod(keepAlive: true)
LocalNotifications localNotifications(Ref ref) => LocalNotifications();

/// Route a notification asked to open, waiting for the app to be able to
/// show it (after the splash, with a session). See `FbuApp`.
@Riverpod(keepAlive: true)
class PendingNotificationRoute extends _$PendingNotificationRoute {
  @override
  String? build() => null;

  void open(String route) => state = route;

  /// The route, once: it is cleared.
  String? take() {
    final route = state;
    state = null;
    return route;
  }
}

/// Where [response] leads, or `null` (e.g. "Confirmar", handled in
/// background, or a payload of another version).
String? routeOfResponse(NotificationResponse response) {
  if (response.actionId == NotificationActions.confirm) return null;
  final message = LocalNotifications.messageOf(response);
  if (message == null) return null;
  return NotificationContent.routeOf(
    message,
    reject: response.actionId == NotificationActions.reject,
  );
}

/// Sets the local notifications up once Firebase is ready: taps while the
/// app runs, and the tap that launched it.
@Riverpod(keepAlive: true)
Future<void> notificationsSetup(Ref ref) async {
  await ref.watch(appStartupProvider.future);
  final local = ref.watch(localNotificationsProvider);
  final pending = ref.read(pendingNotificationRouteProvider.notifier);
  void handle(NotificationResponse response) {
    final route = routeOfResponse(response);
    if (route != null) pending.open(route);
  }

  try {
    await local.initialize(
      onResponse: handle,
      onBackgroundResponse: onBackgroundNotificationResponse,
    );
    final launch = await local.launchResponse();
    if (launch != null) handle(launch);
  } catch (error, stackTrace) {
    developer.log(
      'Could not set the notifications up',
      name: 'fbu.notifications',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// While someone is signed in: keeps this device's token in
/// `users/{uid}/fcmTokens` and draws the messages that arrive with the app
/// in foreground (FCM only wakes the background handler when it is not).
///
/// Kept alive for the whole session from `FbuApp`.
@Riverpod(keepAlive: true)
Future<void> pushSync(Ref ref) async {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) return;
  await ref.watch(notificationsSetupProvider.future);
  final registration = ref.watch(pushRegistrationProvider);
  final local = ref.watch(localNotificationsProvider);

  Future<void> guard(String what, Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      developer.log(
        what,
        name: 'fbu.notifications',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  final refreshes = registration.tokenRefreshes.listen(
    (token) => guard(
      'Could not save the new push token',
      () => registration.save(user.uid, token),
    ),
  );
  final foreground = FirebaseMessaging.onMessage.listen((remote) {
    final message = PushMessage.parse(remote.data);
    if (message == null || message.recipientUid != user.uid) return;
    guard('Could not show a push', () => local.show(message));
  });
  ref.onDispose(() {
    unawaited(refreshes.cancel());
    unawaited(foreground.cancel());
  });

  await guard(
    'Could not register for push notifications',
    () => registration.register(user.uid),
  );
}

/// Asks for the notifications permission (Android 13+) the first time the
/// user reaches the Home; never again after that, whatever they answer
/// (they can turn them on in the system settings).
@Riverpod(keepAlive: true)
NotificationPermissionPrompt notificationPermissionPrompt(Ref ref) =>
    NotificationPermissionPrompt(ref.watch(localNotificationsProvider));

class NotificationPermissionPrompt {
  NotificationPermissionPrompt(
    this._notifications, {
    SharedPreferencesAsync Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync.new;

  final LocalNotifications _notifications;

  /// Created when used: without the platform (tests) it throws.
  final SharedPreferencesAsync Function() _preferences;

  static const String askedKey = 'fbu.notifications_asked';

  /// Never throws.
  Future<void> askOnce() async {
    try {
      final preferences = _preferences();
      if (await preferences.getBool(askedKey) ?? false) return;
      await preferences.setBool(askedKey, true);
      await _notifications.requestPermission();
    } catch (error, stackTrace) {
      developer.log(
        'Could not ask for the notifications permission',
        name: 'fbu.notifications',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
