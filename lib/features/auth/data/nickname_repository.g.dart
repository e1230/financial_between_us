// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(nicknameRepository)
final nicknameRepositoryProvider = NicknameRepositoryProvider._();

final class NicknameRepositoryProvider
    extends
        $FunctionalProvider<
          NicknameRepository,
          NicknameRepository,
          NicknameRepository
        >
    with $Provider<NicknameRepository> {
  NicknameRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nicknameRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nicknameRepositoryHash();

  @$internal
  @override
  $ProviderElement<NicknameRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NicknameRepository create(Ref ref) {
    return nicknameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NicknameRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NicknameRepository>(value),
    );
  }
}

String _$nicknameRepositoryHash() =>
    r'b67f556341e5d551a9b4ae2d77136062f7442dcc';
