import 'dart:typed_data';

import 'package:financial_between_us/core/theme/app_theme.dart';
import 'package:financial_between_us/core/widgets/user_avatar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget avatar) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      home: Center(child: avatar),
    ),
  );

  testWidgets('without a photo shows the initial over the color', (
    tester,
  ) async {
    await pump(
      tester,
      const UserAvatar(initial: 'M', color: Color(0xFF4FC3F7), size: 48),
    );
    expect(find.text('M'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(UserAvatar),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect((box.decoration as BoxDecoration).color, const Color(0xFF4FC3F7));
  });

  testWidgets('a photo that fails to load falls back to the initial', (
    tester,
  ) async {
    await pump(
      tester,
      UserAvatar(
        initial: 'M',
        color: const Color(0xFF4FC3F7),
        size: 48,
        image: MemoryImage(Uint8List(0)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
  });
}
