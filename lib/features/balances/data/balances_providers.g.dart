// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balances_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(balancesRepository)
final balancesRepositoryProvider = BalancesRepositoryProvider._();

final class BalancesRepositoryProvider
    extends
        $FunctionalProvider<
          BalancesRepository,
          BalancesRepository,
          BalancesRepository
        >
    with $Provider<BalancesRepository> {
  BalancesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'balancesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$balancesRepositoryHash();

  @$internal
  @override
  $ProviderElement<BalancesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BalancesRepository create(Ref ref) {
    return balancesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BalancesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BalancesRepository>(value),
    );
  }
}

String _$balancesRepositoryHash() =>
    r'555e9d9c7d31fb4cbd07dc0f5690783bd2bb85af';

/// Live debts of [groupId]; empty when the user is not in the group.

@ProviderFor(groupDebts)
final groupDebtsProvider = GroupDebtsFamily._();

/// Live debts of [groupId]; empty when the user is not in the group.

final class GroupDebtsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Debt>>,
          List<Debt>,
          Stream<List<Debt>>
        >
    with $FutureModifier<List<Debt>>, $StreamProvider<List<Debt>> {
  /// Live debts of [groupId]; empty when the user is not in the group.
  GroupDebtsProvider._({
    required GroupDebtsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupDebtsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupDebtsHash();

  @override
  String toString() {
    return r'groupDebtsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Debt>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Debt>> create(Ref ref) {
    final argument = this.argument as String;
    return groupDebts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupDebtsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupDebtsHash() => r'be3c2184476f4121759f98c2d058f7bccc9ba88d';

/// Live debts of [groupId]; empty when the user is not in the group.

final class GroupDebtsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Debt>>, String> {
  GroupDebtsFamily._()
    : super(
        retry: null,
        name: r'groupDebtsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live debts of [groupId]; empty when the user is not in the group.

  GroupDebtsProvider call(String groupId) =>
      GroupDebtsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupDebtsProvider';
}

/// Balance of the signed-in user with each member of [groupId] (see
/// [balancesWith]): positive "Te debe", negative "Debes", absent "a mano".

@ProviderFor(myBalances)
final myBalancesProvider = MyBalancesFamily._();

/// Balance of the signed-in user with each member of [groupId] (see
/// [balancesWith]): positive "Te debe", negative "Debes", absent "a mano".

final class MyBalancesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          FutureOr<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  /// Balance of the signed-in user with each member of [groupId] (see
  /// [balancesWith]): positive "Te debe", negative "Debes", absent "a mano".
  MyBalancesProvider._({
    required MyBalancesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myBalancesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myBalancesHash();

  @override
  String toString() {
    return r'myBalancesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    final argument = this.argument as String;
    return myBalances(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyBalancesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myBalancesHash() => r'ecc68caf89719dc80b8bc431770d50cd60538d53';

/// Balance of the signed-in user with each member of [groupId] (see
/// [balancesWith]): positive "Te debe", negative "Debes", absent "a mano".

final class MyBalancesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, int>>, String> {
  MyBalancesFamily._()
    : super(
        retry: null,
        name: r'myBalancesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Balance of the signed-in user with each member of [groupId] (see
  /// [balancesWith]): positive "Te debe", negative "Debes", absent "a mano".

  MyBalancesProvider call(String groupId) =>
      MyBalancesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'myBalancesProvider';
}
