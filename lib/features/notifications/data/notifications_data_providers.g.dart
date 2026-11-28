// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sends events to the notifications Worker at `NOTIFICATIONS_WORKER_URL`
/// (`.env`). Without it (tests, a clone without `.env`) nothing is sent.

@ProviderFor(notificationDispatcher)
final notificationDispatcherProvider = NotificationDispatcherProvider._();

/// Sends events to the notifications Worker at `NOTIFICATIONS_WORKER_URL`
/// (`.env`). Without it (tests, a clone without `.env`) nothing is sent.

final class NotificationDispatcherProvider
    extends
        $FunctionalProvider<
          NotificationDispatcher,
          NotificationDispatcher,
          NotificationDispatcher
        >
    with $Provider<NotificationDispatcher> {
  /// Sends events to the notifications Worker at `NOTIFICATIONS_WORKER_URL`
  /// (`.env`). Without it (tests, a clone without `.env`) nothing is sent.
  NotificationDispatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationDispatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationDispatcherHash();

  @$internal
  @override
  $ProviderElement<NotificationDispatcher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationDispatcher create(Ref ref) {
    return notificationDispatcher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationDispatcher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationDispatcher>(value),
    );
  }
}

String _$notificationDispatcherHash() =>
    r'99da88dbe090ef52c26891f56175a9ba09df6c03';

/// The [FirebaseMessaging] instance. Only read it after app startup.

@ProviderFor(firebaseMessaging)
final firebaseMessagingProvider = FirebaseMessagingProvider._();

/// The [FirebaseMessaging] instance. Only read it after app startup.

final class FirebaseMessagingProvider
    extends
        $FunctionalProvider<
          FirebaseMessaging,
          FirebaseMessaging,
          FirebaseMessaging
        >
    with $Provider<FirebaseMessaging> {
  /// The [FirebaseMessaging] instance. Only read it after app startup.
  FirebaseMessagingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseMessagingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseMessagingHash();

  @$internal
  @override
  $ProviderElement<FirebaseMessaging> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseMessaging create(Ref ref) {
    return firebaseMessaging(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseMessaging value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseMessaging>(value),
    );
  }
}

String _$firebaseMessagingHash() => r'6765ce963b9b8c50186b5132356d60eb68265741';

@ProviderFor(pushTokenRepository)
final pushTokenRepositoryProvider = PushTokenRepositoryProvider._();

final class PushTokenRepositoryProvider
    extends
        $FunctionalProvider<
          PushTokenRepository,
          PushTokenRepository,
          PushTokenRepository
        >
    with $Provider<PushTokenRepository> {
  PushTokenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenRepositoryHash();

  @$internal
  @override
  $ProviderElement<PushTokenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushTokenRepository create(Ref ref) {
    return pushTokenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushTokenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushTokenRepository>(value),
    );
  }
}

String _$pushTokenRepositoryHash() =>
    r'aa0436acf53138368c2edbf1128ca80cef9d9161';

/// Registers and unregisters this device for the signed-in user.

@ProviderFor(pushRegistration)
final pushRegistrationProvider = PushRegistrationProvider._();

/// Registers and unregisters this device for the signed-in user.

final class PushRegistrationProvider
    extends
        $FunctionalProvider<
          PushRegistration,
          PushRegistration,
          PushRegistration
        >
    with $Provider<PushRegistration> {
  /// Registers and unregisters this device for the signed-in user.
  PushRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushRegistrationHash();

  @$internal
  @override
  $ProviderElement<PushRegistration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PushRegistration create(Ref ref) {
    return pushRegistration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushRegistration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushRegistration>(value),
    );
  }
}

String _$pushRegistrationHash() => r'14717714a05e9bf8f8bed4f629f1e4c8295731c7';
