import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshot_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('settings English light', (tester) async {
    await pumpExampleApp(tester);
    await saveScreenshot(tester, 'settings-en');
  });

  testWidgets('settings English dark', (tester) async {
    await pumpExampleApp(tester, themeMode: 'dark');
    await saveScreenshot(tester, 'settings-en-dark');
  });

  testWidgets('settings Arabic light', (tester) async {
    await pumpExampleApp(tester, language: 'ar');
    await saveScreenshot(tester, 'settings-ar');
  });

  testWidgets('settings Arabic dark', (tester) async {
    await pumpExampleApp(tester, language: 'ar', themeMode: 'dark');
    await saveScreenshot(tester, 'settings-ar-dark');
  });

  testWidgets('search English', (tester) async {
    await pumpExampleApp(tester);
    await tester.tap(
      find.byKey(const ValueKey('safaeh_settings_search_button')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('safaeh_settings_search_field')),
      'theme',
    );
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'search-en');
  });

  testWidgets('search Arabic', (tester) async {
    await pumpExampleApp(tester, language: 'ar');
    await tester.tap(
      find.byKey(const ValueKey('safaeh_settings_search_button')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('safaeh_settings_search_field')),
      'مظهر',
    );
    await tester.pumpAndSettle();
    await saveScreenshot(tester, 'search-ar');
  });
}
