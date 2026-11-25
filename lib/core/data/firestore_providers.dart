import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firestore_providers.g.dart';

/// The [FirebaseFirestore] instance. Only read it after `appStartupProvider`
/// has completed. Overridden in tests.
@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;
