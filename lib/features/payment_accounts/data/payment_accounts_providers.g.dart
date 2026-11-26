// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_accounts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentAccountsRepository)
final paymentAccountsRepositoryProvider = PaymentAccountsRepositoryProvider._();

final class PaymentAccountsRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentAccountsRepository,
          PaymentAccountsRepository,
          PaymentAccountsRepository
        >
    with $Provider<PaymentAccountsRepository> {
  PaymentAccountsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentAccountsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentAccountsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentAccountsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentAccountsRepository create(Ref ref) {
    return paymentAccountsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentAccountsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentAccountsRepository>(value),
    );
  }
}

String _$paymentAccountsRepositoryHash() =>
    r'6fb3277ab2487548fbf9cbb77f1670cb035bbf27';

/// Live payment accounts of the signed-in user, oldest first. Empty when
/// signed out.

@ProviderFor(myPaymentAccounts)
final myPaymentAccountsProvider = MyPaymentAccountsProvider._();

/// Live payment accounts of the signed-in user, oldest first. Empty when
/// signed out.

final class MyPaymentAccountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentAccount>>,
          List<PaymentAccount>,
          Stream<List<PaymentAccount>>
        >
    with
        $FutureModifier<List<PaymentAccount>>,
        $StreamProvider<List<PaymentAccount>> {
  /// Live payment accounts of the signed-in user, oldest first. Empty when
  /// signed out.
  MyPaymentAccountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myPaymentAccountsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myPaymentAccountsHash();

  @$internal
  @override
  $StreamProviderElement<List<PaymentAccount>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PaymentAccount>> create(Ref ref) {
    return myPaymentAccounts(ref);
  }
}

String _$myPaymentAccountsHash() => r'54534d1ad5509bac5065bdbb9363ecbd7c2d4ff6';

/// The account [accountId] of the signed-in user, or `null` once deleted.

@ProviderFor(myPaymentAccountById)
final myPaymentAccountByIdProvider = MyPaymentAccountByIdFamily._();

/// The account [accountId] of the signed-in user, or `null` once deleted.

final class MyPaymentAccountByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaymentAccount?>,
          PaymentAccount?,
          FutureOr<PaymentAccount?>
        >
    with $FutureModifier<PaymentAccount?>, $FutureProvider<PaymentAccount?> {
  /// The account [accountId] of the signed-in user, or `null` once deleted.
  MyPaymentAccountByIdProvider._({
    required MyPaymentAccountByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myPaymentAccountByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myPaymentAccountByIdHash();

  @override
  String toString() {
    return r'myPaymentAccountByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PaymentAccount?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaymentAccount?> create(Ref ref) {
    final argument = this.argument as String;
    return myPaymentAccountById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyPaymentAccountByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myPaymentAccountByIdHash() =>
    r'314921f0bf89a69094c0c9757469b7fb19b51bc9';

/// The account [accountId] of the signed-in user, or `null` once deleted.

final class MyPaymentAccountByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PaymentAccount?>, String> {
  MyPaymentAccountByIdFamily._()
    : super(
        retry: null,
        name: r'myPaymentAccountByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The account [accountId] of the signed-in user, or `null` once deleted.

  MyPaymentAccountByIdProvider call(String accountId) =>
      MyPaymentAccountByIdProvider._(argument: accountId, from: this);

  @override
  String toString() => r'myPaymentAccountByIdProvider';
}
