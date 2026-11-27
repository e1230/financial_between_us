import 'package:financial_between_us/core/platform/share_service.dart';
import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/balances/data/balances_providers.dart';
import 'package:financial_between_us/features/groups/data/groups_providers.dart';
import 'package:financial_between_us/features/groups/data/selected_group_repository.dart';
import 'package:financial_between_us/features/groups/domain/group.dart';
import 'package:financial_between_us/features/home/data/home_activity_repository.dart';
import 'package:financial_between_us/features/home/data/home_providers.dart';
import 'package:financial_between_us/features/payment_accounts/data/payment_accounts_providers.dart';
import 'package:financial_between_us/features/payment_accounts/domain/payment_account.dart';
import 'package:financial_between_us/features/profile/data/profile_providers.dart';
import 'package:financial_between_us/features/profile/domain/user_profile.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fakes.dart';
import '../../support/group_fakes.dart';
import '../../support/movements_fakes.dart';
import '../../support/payment_accounts_fakes.dart';

const UserProfile balancesMe = UserProfile(
  uid: sampleMe,
  displayName: 'Mauricio Beltrán',
  nickname: 'mao',
  email: 'mao@correo.com',
  colorValue: 0xFF6C63FF,
  profileCompleted: true,
);

/// The three groups of the captures.
List<Group> sampleGroups() => [
  Group(
    id: sampleGroupId,
    name: 'Low IQ Group',
    code: 'LIQ-7K4P',
    ownerUid: sampleMe,
    memberUids: const [sampleMe, ...sampleLowIqMembers],
    createdAt: DateTime(2026, 1),
  ),
  Group(
    id: sampleFutbolId,
    name: 'Fútbol de los jueves',
    code: 'FUT-2345',
    ownerUid: 'santi',
    memberUids: const ['santi', sampleMe],
    createdAt: DateTime(2026, 2),
  ),
  Group(
    id: sampleTripId,
    name: 'Viaje a Villa de Leyva',
    code: 'VIL-2345',
    ownerUid: 'tomas',
    memberUids: const ['tomas', sampleMe, 'valen'],
    createdAt: DateTime(2026, 3),
  ),
];

/// What the balances tests can inspect after pumping.
class BalancesHarness {
  BalancesHarness({
    required this.movements,
    required this.share,
    required this.picker,
    required this.uploader,
    required this.router,
    required this.copied,
  });

  final FakeMovementsRepository movements;
  final FakeShareService share;
  final FakeReceiptPicker picker;
  final FakeReceiptUploader uploader;
  final GoRouter router;
  final List<String> copied;
}

/// Mounts the signed-in app at [location] with the data of the captures.
Future<BalancesHarness> pumpBalances(
  WidgetTester tester, {
  String location = AppRoutes.balances,
  List<Group>? groups,
  FakeMovementsRepository? movements,
  Size size = const Size(360, 800),
  double textScale = 1,
  bool reduceMotion = false,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        copied.add((call.arguments as Map)['text'] as String);
      }
      return null;
    },
  );

  final repo = movements ?? FakeMovementsRepository(sampleMovements());
  final share = FakeShareService();
  final picker = FakeReceiptPicker();
  final uploader = FakeReceiptUploader();
  final accounts = FakePaymentAccountsRepository(
    accounts: sampleAccounts(),
    others: {
      'carlosm': [
        PaymentAccount(
          id: 'c1',
          name: 'Nequi',
          type: PaymentAccountType.nequi,
          reference: '3112223344',
          createdAt: DateTime(2026),
        ),
        PaymentAccount(
          id: 'c2',
          name: 'Bre-B',
          type: PaymentAccountType.breb,
          keyType: BrebKeyType.alias,
          reference: '@carlosm',
          createdAt: DateTime(2026, 1, 2),
        ),
      ],
    },
  );
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [homeShellRoute(), ...overShellRoutes()],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateChangesProvider.overrideWith(
          (ref) => Stream.value(FakeUser(uid: sampleMe)),
        ),
        currentUserProfileProvider.overrideWith(
          (ref) => Stream.value(balancesMe),
        ),
        userProfileRepositoryProvider.overrideWithValue(
          FakeUserProfileRepository(
            profiles: {...sampleProfiles, sampleMe: balancesMe},
          ),
        ),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        groupsRepositoryProvider.overrideWithValue(
          FakeGroupsRepository(groups: groups ?? sampleGroups()),
        ),
        selectedGroupRepositoryProvider.overrideWithValue(
          SelectedGroupRepository(FakeSharedPreferencesAsync()),
        ),
        homeActivityRepositoryProvider.overrideWithValue(
          FakeHomeActivityRepository(clock: () => DateTime(2026, 11, 25, 21)),
        ),
        appVersionProvider.overrideWith((ref) async => '1.0.0'),
        paymentAccountsRepositoryProvider.overrideWithValue(accounts),
        shareServiceProvider.overrideWithValue(share),
        movementsRepositoryProvider.overrideWithValue(repo),
        receiptPickerProvider.overrideWithValue(picker),
        receiptUploaderProvider.overrideWithValue(uploader),
      ],
      child: MaterialApp.router(
        theme: AppTheme.withAccent(const Color(0xFF6C63FF)),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: reduceMotion,
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (location != AppRoutes.home) {
    router.go(location);
    await tester.pumpAndSettle();
  }
  return BalancesHarness(
    movements: repo,
    share: share,
    picker: picker,
    uploader: uploader,
    router: router,
    copied: copied,
  );
}

/// Taps [finder] (scrolling it to the middle of the view first when it is
/// hidden, so no pinned bar covers it) and settles.
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  if (finder.hitTestable().evaluate().isEmpty) {
    await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
    await tester.pumpAndSettle();
  }
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
