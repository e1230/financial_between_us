import 'dart:async';

import 'package:financial_between_us/core/branding/fbu_emblem.dart';
import 'package:financial_between_us/core/startup/initial_destination.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/theme/app_tokens.dart';
import 'package:financial_between_us/features/splash/presentation/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the splash keeps the brand green over the user color', (
    tester,
  ) async {
    final pending = Completer<InitialDestination>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialDestinationProvider.overrideWith((ref) => pending.future),
        ],
        child: MaterialApp(
          // A signed-in user with a coral accent.
          theme: AppTheme.withAccent(const Color(0xFFFF8A65)),
          home: const SplashScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final context = tester.element(find.byType(FbuEmblem));
    expect(context.tokens.accent, AppTokens.dark.accent);
  });
}
