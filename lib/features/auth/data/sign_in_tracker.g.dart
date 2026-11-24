// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_in_tracker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Marks `fbu.has_ever_signed_in` the first time a user signs in on this
/// device, whatever the method (email, username, sign-up or Google).
///
/// Listening to `authStateChanges()` here means sign-in screens don't need to
/// remember to do it. Kept alive for the whole app session from `FbuApp`.

@ProviderFor(signInTracker)
final signInTrackerProvider = SignInTrackerProvider._();

/// Marks `fbu.has_ever_signed_in` the first time a user signs in on this
/// device, whatever the method (email, username, sign-up or Google).
///
/// Listening to `authStateChanges()` here means sign-in screens don't need to
/// remember to do it. Kept alive for the whole app session from `FbuApp`.

final class SignInTrackerProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Marks `fbu.has_ever_signed_in` the first time a user signs in on this
  /// device, whatever the method (email, username, sign-up or Google).
  ///
  /// Listening to `authStateChanges()` here means sign-in screens don't need to
  /// remember to do it. Kept alive for the whole app session from `FbuApp`.
  SignInTrackerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInTrackerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInTrackerHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return signInTracker(ref);
  }
}

String _$signInTrackerHash() => r'33f7e7cd2a13e85ca8d2892f8e4ffb9b67eecd96';
