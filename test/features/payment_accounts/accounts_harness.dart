import 'package:financial_between_us/core/platform/share_service.dart';
import 'package:financial_between_us/core/router/app_router.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/features/auth/data/auth_providers.dart';
import 'package:financial_between_us/features/auth/data/auth_repository.dart';
import 'package:financial_between_us/features/balances/data/balances_providers.dart';
import 'package:financial_between_us/features/groups/data/groups_providers.dart';
import 'package:financial_between_us/features/groups/data/selected_group_repository.dart';
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
import '../../support/movements_fakes.dart';
import '../../support/group_fakes.dart';
import '../../support/payment_accounts_fakes.dart';

const accountsUid = 'me';

const _profile = UserProfile(
  uid: accountsUid,
  displayName: 'Juan Pérez',
  nickname: 'juan',
  email: 'juan@correo.com',
  colorValue: 0xFF9FA8DA,
  profileCompleted: true,
);

/// What the app copied to the clipboard and whether it vibrated.
class PlatformLog {
  final List<String> copied = [];
  int vibrations = 0;
}

/// Mounts the app router (Home shell and the pages over it) with the
/// payment accounts of [repository], then opens [location].
Future<PlatformLog> pumpAccounts(
  WidgetTester tester, {
  required FakePaymentAccountsRepository repository,
  FakeShareService? share,
  Stream<List<PaymentAccount>>? accounts,
  String location = AppRoutes.accounts,
  Size size = const Size(360, 800),
  double textScale = 1,
  bool reduceMotion = false,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final log = PlatformLog();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        log.copied.add((call.arguments as Map)['text'] as String);
      } else if (call.method == 'HapticFeedback.vibrate') {
        log.vibrations++;
      }
      return null;
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
          (ref) => Stream.value(FakeUser(uid: accountsUid)),
        ),
        currentUserProfileProvider.overrideWith(
          (ref) => Stream.value(_profile),
        ),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        groupsRepositoryProvider.overrideWithValue(FakeGroupsRepository()),
        selectedGroupRepositoryProvider.overrideWithValue(
          SelectedGroupRepository(FakeSharedPreferencesAsync()),
        ),
        homeActivityRepositoryProvider.overrideWithValue(
          FakeHomeActivityRepository(clock: () => DateTime(2026, 11, 25, 21)),
        ),
        appVersionProvider.overrideWith((ref) async => '1.0.0'),
        movementsRepositoryProvider.overrideWithValue(
          FakeMovementsRepository(),
        ),
        paymentAccountsRepositoryProvider.overrideWithValue(repository),
        if (accounts != null)
          myPaymentAccountsProvider.overrideWith((ref) => accounts),
        shareServiceProvider.overrideWithValue(share ?? FakeShareService()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.withAccent(const Color(0xFF9FA8DA)),
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
    router.push(location);
    await tester.pumpAndSettle();
  }
  return log;
}

/// Lets toasts and "Copiado" states time out, so no timer is left.
Future<void> settleTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
