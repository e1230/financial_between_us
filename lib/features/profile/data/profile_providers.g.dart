// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfileRepository)
final userProfileRepositoryProvider = UserProfileRepositoryProvider._();

final class UserProfileRepositoryProvider
    extends
        $FunctionalProvider<
          UserProfileRepository,
          UserProfileRepository,
          UserProfileRepository
        >
    with $Provider<UserProfileRepository> {
  UserProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileRepository create(Ref ref) {
    return userProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileRepository>(value),
    );
  }
}

String _$userProfileRepositoryHash() =>
    r'80588ebd0227674adf93b6880c36957b9dddc383';

/// Cloudinary uploader configured from `.env` (loaded by app startup).

@ProviderFor(avatarUploader)
final avatarUploaderProvider = AvatarUploaderProvider._();

/// Cloudinary uploader configured from `.env` (loaded by app startup).

final class AvatarUploaderProvider
    extends $FunctionalProvider<AvatarUploader, AvatarUploader, AvatarUploader>
    with $Provider<AvatarUploader> {
  /// Cloudinary uploader configured from `.env` (loaded by app startup).
  AvatarUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarUploaderHash();

  @$internal
  @override
  $ProviderElement<AvatarUploader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AvatarUploader create(Ref ref) {
    return avatarUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvatarUploader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvatarUploader>(value),
    );
  }
}

String _$avatarUploaderHash() => r'bc34ae254a361d8a8760762bb02229553f3faa2c';

@ProviderFor(avatarPicker)
final avatarPickerProvider = AvatarPickerProvider._();

final class AvatarPickerProvider
    extends $FunctionalProvider<AvatarPicker, AvatarPicker, AvatarPicker>
    with $Provider<AvatarPicker> {
  AvatarPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarPickerHash();

  @$internal
  @override
  $ProviderElement<AvatarPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AvatarPicker create(Ref ref) {
    return avatarPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvatarPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvatarPicker>(value),
    );
  }
}

String _$avatarPickerHash() => r'699f0ba878958d629e0dcfe47544a79c8ca462d7';

/// Live profile of the signed-in user; `null` when signed out or while
/// `users/{uid}` does not exist yet.

@ProviderFor(currentUserProfile)
final currentUserProfileProvider = CurrentUserProfileProvider._();

/// Live profile of the signed-in user; `null` when signed out or while
/// `users/{uid}` does not exist yet.

final class CurrentUserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          Stream<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $StreamProvider<UserProfile?> {
  /// Live profile of the signed-in user; `null` when signed out or while
  /// `users/{uid}` does not exist yet.
  CurrentUserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @$internal
  @override
  $StreamProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile?> create(Ref ref) {
    return currentUserProfile(ref);
  }
}

String _$currentUserProfileHash() =>
    r'523631441344b09cec8b7ee26c80b119d15b3fa4';

/// Live profile of any user (friends see each other's name, nickname,
/// photo and color); `null` if it does not exist.

@ProviderFor(userProfile)
final userProfileProvider = UserProfileFamily._();

/// Live profile of any user (friends see each other's name, nickname,
/// photo and color); `null` if it does not exist.

final class UserProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserProfile?>,
          UserProfile?,
          Stream<UserProfile?>
        >
    with $FutureModifier<UserProfile?>, $StreamProvider<UserProfile?> {
  /// Live profile of any user (friends see each other's name, nickname,
  /// photo and color); `null` if it does not exist.
  UserProfileProvider._({
    required UserProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return userProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'fd549f054927e903e6493107a56fd6fffeebafae';

/// Live profile of any user (friends see each other's name, nickname,
/// photo and color); `null` if it does not exist.

final class UserProfileFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserProfile?>, String> {
  UserProfileFamily._()
    : super(
        retry: null,
        name: r'userProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live profile of any user (friends see each other's name, nickname,
  /// photo and color); `null` if it does not exist.

  UserProfileProvider call(String uid) =>
      UserProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'userProfileProvider';
}
