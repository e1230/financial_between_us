import 'package:financial_between_us/core/branding/fbu_logo.dart';
import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pumpLogo(WidgetTester tester, {bool showWordmark = true}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Center(child: FbuLogo(showWordmark: showWordmark)),
        ),
      ),
    );
  }

  testWidgets('exposes the app name to accessibility services', (tester) async {
    await pumpLogo(tester);
    expect(find.bySemanticsLabel('Financial Between Us'), findsOneWidget);
    expect(find.bySemanticsLabel('FBU'), findsOneWidget);
  });

  testWidgets('can hide the wordmark', (tester) async {
    await pumpLogo(tester, showWordmark: false);
    expect(find.bySemanticsLabel('Financial Between Us'), findsOneWidget);
    expect(find.bySemanticsLabel('FBU'), findsNothing);
  });
}
