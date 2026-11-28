// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localNotifications)
final localNotificationsProvider = LocalNotificationsProvider._();

final class LocalNotificationsProvider
    extends
        $FunctionalProvider<
          LocalNotifications,
          LocalNotifications,
          LocalNotifications
        >
    with $Provider<LocalNotifications> {
  LocalNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotificationsHash();

  @$internal
  @override
  $ProviderElement<LocalNotifications> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalNotifications create(Ref ref) {
    return localNotifications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotifications value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotifications>(value),
    );
  }
}

String _$localNotificationsHash() =>
    r'85060b88a1b9af972f0bd3780a612db25e98d535';

/// Route a notification asked to open, waiting for the app to be able to
/// show it (after the splash, with a session). See `FbuApp`.

@ProviderFor(PendingNotificationRoute)
final pendingNotificationRouteProvider = PendingNotificationRouteProvider._();

/// Route a notification asked to open, waiting for the app to be able to
/// show it (after the splash, with a session). See `FbuApp`.
final class PendingNotificationRouteProvider
    extends $NotifierProvider<PendingNotificationRoute, String?> {
  /// Route a notification asked to open, waiting for the app to be able to
  /// show it (after the splash, with a session). See `FbuApp`.
  PendingNotificationRouteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingNotificationRouteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingNotificationRouteHash();

  @$internal
  @override
  PendingNotificationRoute create() => PendingNotificationRoute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingNotificationRouteHash() =>
    r'a00b7e3e66e28145fc111fbcdf505899a812ce7c';

/// Route a notification asked to open, waiting for the app to be able to
/// show it (after the splash, with a session). See `FbuApp`.

abstract class _$PendingNotificationRoute extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sets the local notifications up once Firebase is ready: taps while the
/// app runs, and the tap that launched it.

@ProviderFor(notificationsSetup)
final notificationsSetupProvider = NotificationsSetupProvider._();

/// Sets the local notifications up once Firebase is ready: taps while the
/// app runs, and the tap that launched it.

final class NotificationsSetupProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Sets the local notifications up once Firebase is ready: taps while the
  /// app runs, and the tap that launched it.
  NotificationsSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsSetupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsSetupHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return notificationsSetup(ref);
  }
}

String _$notificationsSetupHash() =>
    r'15712d8868e1287727314f70e811b0fe8ce6731c';

/// While someone is signed in: keeps this device's token in
/// `users/{uid}/fcmTokens` and draws the messages that arrive with the app
/// in foreground (FCM only wakes the background handler when it is not).
///
/// Kept alive for the whole session from `FbuApp`.

@ProviderFor(pushSync)
final pushSyncProvider = PushSyncProvider._();

/// While someone is signed in: keeps this device's token in
/// `users/{uid}/fcmTokens` and draws the messages that arrive with the app
/// in foreground (FCM only wakes the background handler when it is not).
///
/// Kept alive for the whole session from `FbuApp`.

final class PushSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// While someone is signed in: keeps this device's token in
  /// `users/{uid}/fcmTokens` and draws the messages that arrive with the app
  /// in foreground (FCM only wakes the background handler when it is not).
  ///
  /// Kept alive for the whole session from `FbuApp`.
  PushSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return pushSync(ref);
  }
}

String _$pushSyncHash() => r'ea5d1baba43075b19b6070c4f9990b92e033bfa2';

/// Asks for the notifications permission (Android 13+) the first time the
/// user reaches the Home; never again after that, whatever they answer
/// (they can turn them on in the system settings).

@ProviderFor(notificationPermissionPrompt)
final notificationPermissionPromptProvider =
    NotificationPermissionPromptProvider._();

/// Asks for the notifications permission (Android 13+) the first time the
/// user reaches the Home; never again after that, whatever they answer
/// (they can turn them on in the system settings).

final class NotificationPermissionPromptProvider
    extends
        $FunctionalProvider<
          NotificationPermissionPrompt,
          NotificationPermissionPrompt,
          NotificationPermissionPrompt
        >
    with $Provider<NotificationPermissionPrompt> {
  /// Asks for the notifications permission (Android 13+) the first time the
  /// user reaches the Home; never again after that, whatever they answer
  /// (they can turn them on in the system settings).
  NotificationPermissionPromptProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionPromptProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionPromptHash();

  @$internal
  @override
  $ProviderElement<NotificationPermissionPrompt> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPermissionPrompt create(Ref ref) {
    return notificationPermissionPrompt(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPermissionPrompt value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPermissionPrompt>(value),
    );
  }
}

String _$notificationPermissionPromptHash() =>
    r'6f5a3653a750a18dac6e4a7e1e8c7b94ec181bd0';
