// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balances_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(movementsRepository)
final movementsRepositoryProvider = MovementsRepositoryProvider._();

final class MovementsRepositoryProvider
    extends
        $FunctionalProvider<
          MovementsRepository,
          MovementsRepository,
          MovementsRepository
        >
    with $Provider<MovementsRepository> {
  MovementsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'movementsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$movementsRepositoryHash();

  @$internal
  @override
  $ProviderElement<MovementsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MovementsRepository create(Ref ref) {
    return movementsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MovementsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MovementsRepository>(value),
    );
  }
}

String _$movementsRepositoryHash() =>
    r'7e3f6f97db5cd715a4886a4f8dd4b7a9cefd8ead';

@ProviderFor(receiptUploader)
final receiptUploaderProvider = ReceiptUploaderProvider._();

final class ReceiptUploaderProvider
    extends
        $FunctionalProvider<ReceiptUploader, ReceiptUploader, ReceiptUploader>
    with $Provider<ReceiptUploader> {
  ReceiptUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptUploaderHash();

  @$internal
  @override
  $ProviderElement<ReceiptUploader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptUploader create(Ref ref) {
    return receiptUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptUploader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptUploader>(value),
    );
  }
}

String _$receiptUploaderHash() => r'a83d0155266b87e4ea18a789c3eea051ecf481e5';

@ProviderFor(receiptPicker)
final receiptPickerProvider = ReceiptPickerProvider._();

final class ReceiptPickerProvider
    extends $FunctionalProvider<ReceiptPicker, ReceiptPicker, ReceiptPicker>
    with $Provider<ReceiptPicker> {
  ReceiptPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptPickerHash();

  @$internal
  @override
  $ProviderElement<ReceiptPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReceiptPicker create(Ref ref) {
    return receiptPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReceiptPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReceiptPicker>(value),
    );
  }
}

String _$receiptPickerHash() => r'a97c28399c1f8b31980dc6b8963a2150bb3e8008';

@ProviderFor(groupEventsRepository)
final groupEventsRepositoryProvider = GroupEventsRepositoryProvider._();

final class GroupEventsRepositoryProvider
    extends
        $FunctionalProvider<
          GroupEventsRepository,
          GroupEventsRepository,
          GroupEventsRepository
        >
    with $Provider<GroupEventsRepository> {
  GroupEventsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupEventsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupEventsRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupEventsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupEventsRepository create(Ref ref) {
    return groupEventsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupEventsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupEventsRepository>(value),
    );
  }
}

String _$groupEventsRepositoryHash() =>
    r'c68dfd46ad42244b55fd004bd150f6750b87778d';

@ProviderFor(movementActions)
final movementActionsProvider = MovementActionsProvider._();

final class MovementActionsProvider
    extends
        $FunctionalProvider<MovementActions, MovementActions, MovementActions>
    with $Provider<MovementActions> {
  MovementActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'movementActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$movementActionsHash();

  @$internal
  @override
  $ProviderElement<MovementActions> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MovementActions create(Ref ref) {
    return movementActions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MovementActions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MovementActions>(value),
    );
  }
}

String _$movementActionsHash() => r'559d7cf116bbc01e8551750068289d7b2885c757';

/// Events of [groupId] a debt can belong to, newest first.

@ProviderFor(groupEvents)
final groupEventsProvider = GroupEventsFamily._();

/// Events of [groupId] a debt can belong to, newest first.

final class GroupEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupEvent>>,
          List<GroupEvent>,
          Stream<List<GroupEvent>>
        >
    with $FutureModifier<List<GroupEvent>>, $StreamProvider<List<GroupEvent>> {
  /// Events of [groupId] a debt can belong to, newest first.
  GroupEventsProvider._({
    required GroupEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupEventsHash();

  @override
  String toString() {
    return r'groupEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<GroupEvent>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GroupEvent>> create(Ref ref) {
    final argument = this.argument as String;
    return groupEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupEventsHash() => r'09558712712ba285222fc28bbc383ee89a4ac1e0';

/// Events of [groupId] a debt can belong to, newest first.

final class GroupEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<GroupEvent>>, String> {
  GroupEventsFamily._()
    : super(
        retry: null,
        name: r'groupEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Events of [groupId] a debt can belong to, newest first.

  GroupEventsProvider call(String groupId) =>
      GroupEventsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupEventsProvider';
}

/// Live movements of [groupId]; empty when the user is not in the group.
///
/// Not retried on error: Firestore already reconnects by itself, a denied
/// read does not fix itself, and the screens offer "Reintentar".

@ProviderFor(groupMovements)
final groupMovementsProvider = GroupMovementsFamily._();

/// Live movements of [groupId]; empty when the user is not in the group.
///
/// Not retried on error: Firestore already reconnects by itself, a denied
/// read does not fix itself, and the screens offer "Reintentar".

final class GroupMovementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LedgerMovement>>,
          List<LedgerMovement>,
          Stream<List<LedgerMovement>>
        >
    with
        $FutureModifier<List<LedgerMovement>>,
        $StreamProvider<List<LedgerMovement>> {
  /// Live movements of [groupId]; empty when the user is not in the group.
  ///
  /// Not retried on error: Firestore already reconnects by itself, a denied
  /// read does not fix itself, and the screens offer "Reintentar".
  GroupMovementsProvider._({
    required GroupMovementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'groupMovementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMovementsHash();

  @override
  String toString() {
    return r'groupMovementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LedgerMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LedgerMovement>> create(Ref ref) {
    final argument = this.argument as String;
    return groupMovements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMovementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMovementsHash() => r'e3366696932274a2a1eba18836cc36330271d99f';

/// Live movements of [groupId]; empty when the user is not in the group.
///
/// Not retried on error: Firestore already reconnects by itself, a denied
/// read does not fix itself, and the screens offer "Reintentar".

final class GroupMovementsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LedgerMovement>>, String> {
  GroupMovementsFamily._()
    : super(
        retry: _noRetry,
        name: r'groupMovementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live movements of [groupId]; empty when the user is not in the group.
  ///
  /// Not retried on error: Firestore already reconnects by itself, a denied
  /// read does not fix itself, and the screens offer "Reintentar".

  GroupMovementsProvider call(String groupId) =>
      GroupMovementsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupMovementsProvider';
}

/// Live newest movements of [groupId] where the user is a party, read with
/// a limit instead of the whole group.

@ProviderFor(recentGroupMovements)
final recentGroupMovementsProvider = RecentGroupMovementsFamily._();

/// Live newest movements of [groupId] where the user is a party, read with
/// a limit instead of the whole group.

final class RecentGroupMovementsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LedgerMovement>>,
          List<LedgerMovement>,
          Stream<List<LedgerMovement>>
        >
    with
        $FutureModifier<List<LedgerMovement>>,
        $StreamProvider<List<LedgerMovement>> {
  /// Live newest movements of [groupId] where the user is a party, read with
  /// a limit instead of the whole group.
  RecentGroupMovementsProvider._({
    required RecentGroupMovementsFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noRetry,
         name: r'recentGroupMovementsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recentGroupMovementsHash();

  @override
  String toString() {
    return r'recentGroupMovementsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LedgerMovement>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LedgerMovement>> create(Ref ref) {
    final argument = this.argument as String;
    return recentGroupMovements(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentGroupMovementsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recentGroupMovementsHash() =>
    r'd31046cac49b3fe92121eb01d44e0cecea6dee2e';

/// Live newest movements of [groupId] where the user is a party, read with
/// a limit instead of the whole group.

final class RecentGroupMovementsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LedgerMovement>>, String> {
  RecentGroupMovementsFamily._()
    : super(
        retry: _noRetry,
        name: r'recentGroupMovementsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live newest movements of [groupId] where the user is a party, read with
  /// a limit instead of the whole group.

  RecentGroupMovementsProvider call(String groupId) =>
      RecentGroupMovementsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'recentGroupMovementsProvider';
}

/// What is still owed between the people of [groupId] (see
/// [debtsFromMovements]).

@ProviderFor(groupDebts)
final groupDebtsProvider = GroupDebtsFamily._();

/// What is still owed between the people of [groupId] (see
/// [debtsFromMovements]).

final class GroupDebtsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Debt>>,
          List<Debt>,
          FutureOr<List<Debt>>
        >
    with $FutureModifier<List<Debt>>, $FutureProvider<List<Debt>> {
  /// What is still owed between the people of [groupId] (see
  /// [debtsFromMovements]).
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
  $FutureProviderElement<List<Debt>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Debt>> create(Ref ref) {
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

String _$groupDebtsHash() => r'1dfc91bf032c3ec5d3e8ed97f052a3a1f1175751';

/// What is still owed between the people of [groupId] (see
/// [debtsFromMovements]).

final class GroupDebtsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Debt>>, String> {
  GroupDebtsFamily._()
    : super(
        retry: null,
        name: r'groupDebtsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What is still owed between the people of [groupId] (see
  /// [debtsFromMovements]).

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

/// Tab of the balances screen; kept while the app is open.

@ProviderFor(SelectedBalancesTab)
final selectedBalancesTabProvider = SelectedBalancesTabProvider._();

/// Tab of the balances screen; kept while the app is open.
final class SelectedBalancesTabProvider
    extends $NotifierProvider<SelectedBalancesTab, BalancesTab> {
  /// Tab of the balances screen; kept while the app is open.
  SelectedBalancesTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedBalancesTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedBalancesTabHash();

  @$internal
  @override
  SelectedBalancesTab create() => SelectedBalancesTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BalancesTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BalancesTab>(value),
    );
  }
}

String _$selectedBalancesTabHash() =>
    r'f519d1009171297c765b628e3e9edbc3afb045d1';

/// Tab of the balances screen; kept while the app is open.

abstract class _$SelectedBalancesTab extends $Notifier<BalancesTab> {
  BalancesTab build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BalancesTab, BalancesTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BalancesTab, BalancesTab>,
              BalancesTab,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Groups of [scope] where the user is an active member: the group (if it
/// still is one of theirs) or all of them.

@ProviderFor(scopeGroups)
final scopeGroupsProvider = ScopeGroupsFamily._();

/// Groups of [scope] where the user is an active member: the group (if it
/// still is one of theirs) or all of them.

final class ScopeGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Group>>,
          List<Group>,
          FutureOr<List<Group>>
        >
    with $FutureModifier<List<Group>>, $FutureProvider<List<Group>> {
  /// Groups of [scope] where the user is an active member: the group (if it
  /// still is one of theirs) or all of them.
  ScopeGroupsProvider._({
    required ScopeGroupsFamily super.from,
    required BalancesScope super.argument,
  }) : super(
         retry: null,
         name: r'scopeGroupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scopeGroupsHash();

  @override
  String toString() {
    return r'scopeGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Group>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Group>> create(Ref ref) {
    final argument = this.argument as BalancesScope;
    return scopeGroups(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ScopeGroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scopeGroupsHash() => r'd03dacfd27e3f0dbb92d7409449e68d174b11a49';

/// Groups of [scope] where the user is an active member: the group (if it
/// still is one of theirs) or all of them.

final class ScopeGroupsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Group>>, BalancesScope> {
  ScopeGroupsFamily._()
    : super(
        retry: null,
        name: r'scopeGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Groups of [scope] where the user is an active member: the group (if it
  /// still is one of theirs) or all of them.

  ScopeGroupsProvider call(BalancesScope scope) =>
      ScopeGroupsProvider._(argument: scope, from: this);

  @override
  String toString() => r'scopeGroupsProvider';
}

/// Movements and members of each group of [scope].

@ProviderFor(scopeLedgerInputs)
final scopeLedgerInputsProvider = ScopeLedgerInputsFamily._();

/// Movements and members of each group of [scope].

final class ScopeLedgerInputsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupLedgerInput>>,
          List<GroupLedgerInput>,
          FutureOr<List<GroupLedgerInput>>
        >
    with
        $FutureModifier<List<GroupLedgerInput>>,
        $FutureProvider<List<GroupLedgerInput>> {
  /// Movements and members of each group of [scope].
  ScopeLedgerInputsProvider._({
    required ScopeLedgerInputsFamily super.from,
    required BalancesScope super.argument,
  }) : super(
         retry: _noRetry,
         name: r'scopeLedgerInputsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scopeLedgerInputsHash();

  @override
  String toString() {
    return r'scopeLedgerInputsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GroupLedgerInput>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GroupLedgerInput>> create(Ref ref) {
    final argument = this.argument as BalancesScope;
    return scopeLedgerInputs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ScopeLedgerInputsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scopeLedgerInputsHash() => r'4c6bc4cfae1ce6f17d43beec0e8444f5adfaf6a9';

/// Movements and members of each group of [scope].

final class ScopeLedgerInputsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<GroupLedgerInput>>,
          BalancesScope
        > {
  ScopeLedgerInputsFamily._()
    : super(
        retry: _noRetry,
        name: r'scopeLedgerInputsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Movements and members of each group of [scope].

  ScopeLedgerInputsProvider call(BalancesScope scope) =>
      ScopeLedgerInputsProvider._(argument: scope, from: this);

  @override
  String toString() => r'scopeLedgerInputsProvider';
}

/// The balances screen of [scope].

@ProviderFor(balancesOverview)
final balancesOverviewProvider = BalancesOverviewFamily._();

/// The balances screen of [scope].

final class BalancesOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<BalancesOverview>,
          BalancesOverview,
          FutureOr<BalancesOverview>
        >
    with $FutureModifier<BalancesOverview>, $FutureProvider<BalancesOverview> {
  /// The balances screen of [scope].
  BalancesOverviewProvider._({
    required BalancesOverviewFamily super.from,
    required BalancesScope super.argument,
  }) : super(
         retry: _noRetry,
         name: r'balancesOverviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$balancesOverviewHash();

  @override
  String toString() {
    return r'balancesOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BalancesOverview> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BalancesOverview> create(Ref ref) {
    final argument = this.argument as BalancesScope;
    return balancesOverview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BalancesOverviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$balancesOverviewHash() => r'6022c5b1c40a2a9d0c4d1e79c263150fd5bd33f3';

/// The balances screen of [scope].

final class BalancesOverviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BalancesOverview>, BalancesScope> {
  BalancesOverviewFamily._()
    : super(
        retry: _noRetry,
        name: r'balancesOverviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The balances screen of [scope].

  BalancesOverviewProvider call(BalancesScope scope) =>
      BalancesOverviewProvider._(argument: scope, from: this);

  @override
  String toString() => r'balancesOverviewProvider';
}

/// The signed-in user's ledger with [otherUid] across the groups of
/// [scope].

@ProviderFor(personLedger)
final personLedgerProvider = PersonLedgerFamily._();

/// The signed-in user's ledger with [otherUid] across the groups of
/// [scope].

final class PersonLedgerProvider
    extends
        $FunctionalProvider<
          AsyncValue<PersonLedger>,
          PersonLedger,
          FutureOr<PersonLedger>
        >
    with $FutureModifier<PersonLedger>, $FutureProvider<PersonLedger> {
  /// The signed-in user's ledger with [otherUid] across the groups of
  /// [scope].
  PersonLedgerProvider._({
    required PersonLedgerFamily super.from,
    required (BalancesScope, String) super.argument,
  }) : super(
         retry: _noRetry,
         name: r'personLedgerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$personLedgerHash();

  @override
  String toString() {
    return r'personLedgerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PersonLedger> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PersonLedger> create(Ref ref) {
    final argument = this.argument as (BalancesScope, String);
    return personLedger(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonLedgerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$personLedgerHash() => r'0072a1e3d284726f9b547de45149d3798214efe8';

/// The signed-in user's ledger with [otherUid] across the groups of
/// [scope].

final class PersonLedgerFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PersonLedger>,
          (BalancesScope, String)
        > {
  PersonLedgerFamily._()
    : super(
        retry: _noRetry,
        name: r'personLedgerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The signed-in user's ledger with [otherUid] across the groups of
  /// [scope].

  PersonLedgerProvider call(BalancesScope scope, String otherUid) =>
      PersonLedgerProvider._(argument: (scope, otherUid), from: this);

  @override
  String toString() => r'personLedgerProvider';
}

/// The history of the signed-in user with [otherUid] in [scope], loaded a
/// page at a time ([historyPageSize] movements) so the server only sends
/// what the user scrolls to. The newest page stays live (new, rejected and
/// deleted movements show up at once); older pages are read once.

@ProviderFor(PairHistory)
final pairHistoryProvider = PairHistoryFamily._();

/// The history of the signed-in user with [otherUid] in [scope], loaded a
/// page at a time ([historyPageSize] movements) so the server only sends
/// what the user scrolls to. The newest page stays live (new, rejected and
/// deleted movements show up at once); older pages are read once.
final class PairHistoryProvider
    extends $StreamNotifierProvider<PairHistory, PairHistoryState> {
  /// The history of the signed-in user with [otherUid] in [scope], loaded a
  /// page at a time ([historyPageSize] movements) so the server only sends
  /// what the user scrolls to. The newest page stays live (new, rejected and
  /// deleted movements show up at once); older pages are read once.
  PairHistoryProvider._({
    required PairHistoryFamily super.from,
    required (BalancesScope, String) super.argument,
  }) : super(
         retry: _noRetry,
         name: r'pairHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pairHistoryHash();

  @override
  String toString() {
    return r'pairHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PairHistory create() => PairHistory();

  @override
  bool operator ==(Object other) {
    return other is PairHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pairHistoryHash() => r'969b5dd399511859a0fcde1af418d2b418c31015';

/// The history of the signed-in user with [otherUid] in [scope], loaded a
/// page at a time ([historyPageSize] movements) so the server only sends
/// what the user scrolls to. The newest page stays live (new, rejected and
/// deleted movements show up at once); older pages are read once.

final class PairHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          PairHistory,
          AsyncValue<PairHistoryState>,
          PairHistoryState,
          Stream<PairHistoryState>,
          (BalancesScope, String)
        > {
  PairHistoryFamily._()
    : super(
        retry: _noRetry,
        name: r'pairHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The history of the signed-in user with [otherUid] in [scope], loaded a
  /// page at a time ([historyPageSize] movements) so the server only sends
  /// what the user scrolls to. The newest page stays live (new, rejected and
  /// deleted movements show up at once); older pages are read once.

  PairHistoryProvider call(BalancesScope scope, String otherUid) =>
      PairHistoryProvider._(argument: (scope, otherUid), from: this);

  @override
  String toString() => r'pairHistoryProvider';
}

/// The history of the signed-in user with [otherUid] in [scope], loaded a
/// page at a time ([historyPageSize] movements) so the server only sends
/// what the user scrolls to. The newest page stays live (new, rejected and
/// deleted movements show up at once); older pages are read once.

abstract class _$PairHistory extends $StreamNotifier<PairHistoryState> {
  late final _$args = ref.$arg as (BalancesScope, String);
  BalancesScope get scope => _$args.$1;
  String get otherUid => _$args.$2;

  Stream<PairHistoryState> build(BalancesScope scope, String otherUid);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PairHistoryState>, PairHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PairHistoryState>, PairHistoryState>,
              AsyncValue<PairHistoryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
