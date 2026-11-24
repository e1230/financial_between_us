import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory [SharedPreferencesAsync] (only booleans are needed).
class FakeSharedPreferencesAsync extends Fake
    implements SharedPreferencesAsync {
  FakeSharedPreferencesAsync([Map<String, bool>? values])
    : values = {...?values};

  final Map<String, bool> values;

  /// Keys written, in order.
  final List<String> writes = [];

  @override
  Future<bool?> getBool(String key) async => values[key];

  @override
  Future<void> setBool(String key, bool value) async {
    writes.add(key);
    values[key] = value;
  }
}

class FakeUser extends Fake implements User {}

/// [FirebaseAuth] with a fixed [currentUser] and a controllable auth stream.
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  FakeFirebaseAuth({this.currentUser});

  @override
  final User? currentUser;

  final StreamController<User?> authStates = StreamController<User?>();

  @override
  Stream<User?> authStateChanges() => authStates.stream;
}
