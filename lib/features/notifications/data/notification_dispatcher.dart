import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../domain/push_event.dart';

/// Tells the notifications Worker that something happened. Never throws:
/// a notification that could not be sent must not undo or block the
/// write that already succeeded.
abstract interface class NotificationDispatcher {
  Future<void> notify(PushEvent event);
}

/// Without a Worker URL (tests, a clone without `.env`): only logs.
class NoopNotificationDispatcher implements NotificationDispatcher {
  const NoopNotificationDispatcher();

  @override
  Future<void> notify(PushEvent event) async {
    developer.log(
      'No notifications Worker configured; skipped ${event.type}',
      name: 'fbu.notifications',
    );
  }
}

/// `POST {baseUrl}/v1/notify` with the Firebase ID token of the user.
class WorkerNotificationDispatcher implements NotificationDispatcher {
  WorkerNotificationDispatcher({
    required Uri baseUrl,
    required this._auth,
    http.Client? client,
  }) : _endpoint = baseUrl.resolve('/v1/notify'),
       _client = client ?? http.Client();

  final Uri _endpoint;
  final FirebaseAuth _auth;
  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 15);

  @override
  Future<void> notify(PushEvent event) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();
      if (token == null) return;
      final response = await _client
          .post(
            _endpoint,
            headers: {
              'authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
            body: jsonEncode(event.toJson()),
          )
          .timeout(_timeout);
      if (response.statusCode >= 300) {
        developer.log(
          'Worker answered ${response.statusCode} to ${event.type}: '
          '${response.body}',
          name: 'fbu.notifications',
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not notify ${event.type}',
        name: 'fbu.notifications',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
