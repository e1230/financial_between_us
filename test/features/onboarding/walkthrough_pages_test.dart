import 'package:financial_between_us/features/onboarding/presentation/walkthrough_pages.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('there are three pages', () {
    expect(walkthroughPages, hasLength(3));
  });

  for (final page in walkthroughPages) {
    test('${page.imageAsset} is bundled', () async {
      final data = await rootBundle.load(page.imageAsset);
      expect(data.lengthInBytes, greaterThan(0));
    });
  }
}
