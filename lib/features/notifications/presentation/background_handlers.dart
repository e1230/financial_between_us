import 'dart:developer' as developer;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../firebase_options.dart';
import '../../balances/data/movements_repository.dart';
import '../domain/push_message.dart';
import 'local_notifications.dart';

// Entry points the platform calls on background isolates, without the
// Riverpod container of the app: each one sets up what it needs.

/// A data message arrived while the app was in background or closed: it is
/// drawn as a notification if it is for the signed-in user.
@pragma('vm:entry-point')
Future<void> onBackgroundPushMessage(RemoteMessage remote) async {
  final message = PushMessage.parse(remote.data);
  if (message == null) return;
  try {
    await _ensureFirebase();
    if (await _signedInUid() != message.recipientUid) return;
    final notifications = LocalNotifications();
    await notifications.initialize(
      onBackgroundResponse: onBackgroundNotificationResponse,
    );
    await notifications.show(message);
  } catch (error, stackTrace) {
    _log('Could not show a background push', error, stackTrace);
  }
}

/// A button that does not open the app ("Confirmar"): marks the movement
/// as seen.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  if (response.actionId != NotificationActions.confirm) return;
  final message = LocalNotifications.messageOf(response);
  if (message is! MovementPush) return;
  try {
    DartPluginRegistrant.ensureInitialized();
    await _ensureFirebase();
    await confirmMovement(
      FirestoreMovementsRepository(FirebaseFirestore.instance),
      message,
      await _signedInUid(),
    );
  } catch (error, stackTrace) {
    _log('Could not confirm a movement', error, stackTrace);
  }
}

/// "Confirmar": [uid], the recipient of [message], has seen its movement.
/// The movement already counts in the balance; nothing else changes.
Future<void> confirmMovement(
  MovementsRepository repository,
  MovementPush message,
  String? uid,
) async {
  if (uid == null || uid != message.recipientUid) return;
  final movement = await repository.fetchMovement(
    groupId: message.groupId,
    movementId: message.movementId,
  );
  if (movement == null) return;
  await repository.markSeen(movement: movement, uid: uid);
}

Future<void> _ensureFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// The persisted session is restored asynchronously, so `currentUser` may
/// still be `null` right after initializing.
Future<String?> _signedInUid() async =>
    (await FirebaseAuth.instance.authStateChanges().first)?.uid;

void _log(String message, Object error, StackTrace stackTrace) => developer.log(
  message,
  name: 'fbu.notifications',
  error: error,
  stackTrace: stackTrace,
);
