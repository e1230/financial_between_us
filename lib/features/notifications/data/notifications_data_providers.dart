import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/firestore_providers.dart';
import '../../auth/data/auth_providers.dart';
import 'notification_dispatcher.dart';
import 'push_token_repository.dart';

part 'notifications_data_providers.g.dart';

/// Sends events to the notifications Worker at `NOTIFICATIONS_WORKER_URL`
/// (`.env`). Without it (tests, a clone without `.env`) nothing is sent.
@Riverpod(keepAlive: true)
NotificationDispatcher notificationDispatcher(Ref ref) {
  final env = dotenv.isInitialized ? dotenv.env : const <String, String>{};
  final baseUrl = Uri.tryParse(env['NOTIFICATIONS_WORKER_URL'] ?? '');
  if (baseUrl == null || !baseUrl.isScheme('https')) {
    return const NoopNotificationDispatcher();
  }
  return WorkerNotificationDispatcher(
    baseUrl: baseUrl,
    auth: ref.watch(firebaseAuthProvider),
  );
}

/// The [FirebaseMessaging] instance. Only read it after app startup.
@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessaging(Ref ref) => FirebaseMessaging.instance;

@Riverpod(keepAlive: true)
PushTokenRepository pushTokenRepository(Ref ref) =>
    FirestorePushTokenRepository(ref.watch(firebaseFirestoreProvider));

/// Registers and unregisters this device for the signed-in user.
@Riverpod(keepAlive: true)
PushRegistration pushRegistration(Ref ref) => PushRegistration(
  messaging: ref.watch(firebaseMessagingProvider),
  tokens: ref.watch(pushTokenRepositoryProvider),
);

// DECISIÓN: firebase_messaging 17 deprecates the registration token in
// favor of Firebase Installation IDs (`register`/`onRegistered`), which need
// an opt-in flag and a send target the FCM HTTP v1 docs do not cover yet.
// The registration token is what HTTP v1 documents, so it is kept; move to
// the FID once its server side is documented.
// ignore_for_file: deprecated_member_use
class PushRegistration {
  PushRegistration({required this._messaging, required this._tokens});

  final FirebaseMessaging _messaging;
  final PushTokenRepository _tokens;

  /// New tokens FCM gives this device.
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  /// This device receives the notifications of [uid].
  Future<void> register(String uid) async {
    final token = await _messaging.getToken();
    if (token != null) await save(uid, token);
  }

  Future<void> save(String uid, String token) =>
      _tokens.save(uid: uid, token: token);

  /// Before signing out: this device stops receiving the notifications of
  /// [uid] (the token is retired and deleted from FCM).
  Future<void> unregister(String uid) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    await _tokens.retire(uid: uid, token: token);
    await _messaging.deleteToken();
  }
}
