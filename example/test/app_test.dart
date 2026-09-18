import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_settings_framework/safaeh.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshot_harness.dart';

Finder get searchButton =>
    find.byKey(const ValueKey('safaeh_settings_search_button'));
Finder get searchField =>
    find.byKey(const ValueKey('safaeh_settings_search_field'));
Finder get searchOverlay =>
    find.byKey(const ValueKey('safaeh_settings_search_overlay'));

Future<void> openSearch(WidgetTester tester) async {
  await tester.tap(searchButton);
  await tester.pumpAndSettle();
}

Finder searchResult(String text) =>
    find.descendant(of: searchOverlay, matching: find.text(text));

/// Account dashboard can push later sections out of the lazy list viewport.
Finder listed(String text) => find.descendant(
  of: find.byKey(const ValueKey('settings_list')),
  matching: find.text(text, skipOffstage: false),
);

Future<void> revealText(WidgetTester tester, String text) async {
  if (listed(text).evaluate().isNotEmpty) return;
  final list = find.byKey(const ValueKey('settings_list'));
  if (list.evaluate().isEmpty) return;
  final target = listed(text);
  for (var i = 0; i < 24 && target.evaluate().isEmpty; i++) {
    await tester.drag(list, const Offset(0, -280));
    await tester.pumpAndSettle();
  }
  if (listed(text).evaluate().isEmpty && target.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(
      listed(text),
      280,
      scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
    );
  }
}

void main() {
  testWidgets('account section shows profile card and inline dashboard', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.text('Account'), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Ada'), findsWidgets);
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.text('Plan usage'), findsOneWidget);
    expect(find.byType(ProfileKpiStrip), findsOneWidget);
    expect(
      find.byType(ProfileBudgetCard, skipOffstage: false),
      findsNWidgets(2),
    );
    expect(
      find.byType(ProfileNotificationTile, skipOffstage: false),
      findsWidgets,
    );
    expect(
      find.byType(ProfileStatusBanner, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byType(ProfilePlanCard, skipOffstage: false), findsOneWidget);
    expect(
      find.byType(ProfileSessionTile, skipOffstage: false),
      findsNWidgets(2),
    );
    expect(
      find.byType(ProfilePlaceholder, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('see all sessions opens a device sheet', (tester) async {
    await pumpExampleApp(tester);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    final seeAll = find.text('See all');
    await tester.ensureVisible(seeAll);
    await tester.pumpAndSettle();
    await tester.tap(seeAll);
    await tester.pumpAndSettle();

    expect(find.text('4 devices signed in'), findsOneWidget);
    expect(find.text('Other devices'), findsOneWidget);
    expect(find.text('iPad'), findsOneWidget);
    expect(find.text('Firefox on Windows'), findsOneWidget);
    expect(find.text('Sign out other devices'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('iPad'), findsNothing);
  });

  testWidgets('search profile finds the account action', (tester) async {
    await pumpExampleApp(tester);

    await openSearch(tester);
    await tester.enterText(searchField, 'profile');
    await tester.pumpAndSettle();
    expect(searchResult('Profile'), findsOneWidget);
  });

  testWidgets('example settings page renders tiles and bilingual search', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    expect(find.text('Edadat'), findsOneWidget);
    await revealText(tester, 'General');
    expect(listed('General'), findsOneWidget);
    await revealText(tester, 'Appearance');
    expect(listed('Appearance'), findsOneWidget);
    await revealText(tester, 'Notifications');
    expect(listed('Notifications'), findsOneWidget);
    await revealText(tester, 'Accent color');
    expect(listed('Accent color'), findsOneWidget);

    await openSearch(tester);
    await tester.enterText(searchField, 'داكن');
    await tester.pumpAndSettle();
    expect(searchResult('Theme'), findsOneWidget);
  });

  testWidgets('search bar filters, shows empty state, and clears', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await openSearch(tester);
    expect(searchField, findsOneWidget);
    expect(
      tester.widget<TextField>(searchField).decoration?.hintText,
      'Search settings...',
    );

    await tester.enterText(searchField, 'zzzznotfound');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: searchOverlay,
        matching: find.textContaining('No settings found'),
      ),
      findsOneWidget,
    );
    expect(listed('General'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('safaeh_settings_search_clear')),
    );
    await tester.pumpAndSettle();
    expect(searchField, findsOneWidget);
    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(listed('General'), findsOneWidget);
    expect(
      find.descendant(
        of: searchOverlay,
        matching: find.textContaining('No settings found'),
      ),
      findsNothing,
    );
  });

  testWidgets('selecting a search result jumps back to the tile', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await openSearch(tester);
    await tester.enterText(searchField, 'theme');
    await tester.pumpAndSettle();
    expect(searchResult('Theme'), findsOneWidget);

    await tester.tap(searchResult('Theme'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(listed('General'), findsOneWidget);
    expect(listed('Theme'), findsWidgets);
    expect(listed('Light'), findsOneWidget);
  });

  testWidgets('layout toggle switches mobile catalog to desktop split', (
    tester,
  ) async {
    await pumpExampleApp(tester);
    await revealText(tester, 'Accent color');
    expect(listed('Accent color'), findsOneWidget);
    expect(find.text('Select a setting to view details'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Select a setting to view details'), findsOneWidget);
    expect(find.text('On this page'), findsOneWidget);
    expect(find.text('Accent color'), findsNothing);

    await tester.tap(listed('Appearance'));
    await tester.pumpAndSettle();
    expect(find.text('Accent color'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Select a setting to view details'), findsNothing);
    expect(listed('Accent color'), findsOneWidget);
    expect(listed('General'), findsOneWidget);
  });

  testWidgets('phone frame wraps the catalog on a wide mobile host', (
    tester,
  ) async {
    await pumpExampleApp(tester);
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 2;
    await tester.pumpAndSettle();

    expect(find.byType(FittedBox), findsOneWidget);
    expect(find.text('Edadat'), findsOneWidget);
    await revealText(tester, 'General');
    expect(listed('General'), findsOneWidget);
    await revealText(tester, 'Accent color');
    expect(listed('Accent color'), findsOneWidget);
    expect(searchButton, findsOneWidget);
  });

  testWidgets('mobile sheets stay inside the fake phone frame', (tester) async {
    await pumpExampleApp(tester);
    tester.view.physicalSize = const Size(1000, 2400);
    await tester.pumpAndSettle();

    final phone = find.byKey(const ValueKey('catalog_phone_frame'));
    final phoneRect = tester.getRect(phone);
    final searchRect = tester.getRect(searchButton);
    expect(searchRect.right, greaterThan(phoneRect.right - 70));

    await tester.ensureVisible(listed('Language'));
    expect(
      identical(
        tester.state<NavigatorState>(
          find.byKey(const ValueKey('catalog_phone_navigator')),
        ),
        Navigator.of(tester.element(listed('Language'))),
      ),
      isTrue,
    );
    await tester.tap(listed('Language'));
    await tester.pumpAndSettle();

    final picker = find.byType(SafaehTilePickerBody<String>);
    expect(picker, findsOneWidget);
    expect(MediaQuery.sizeOf(tester.element(picker)).width, 390);
    expect(MediaQuery.sizeOf(tester.element(picker)).height, 816);
    expect(tester.getRect(picker).bottom, lessThanOrEqualTo(phoneRect.bottom));
  });

  testWidgets('desktop detail pane rebuilds after language change', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();

    await tester.tap(listed('General'));
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsWidgets);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arabic'));
    await tester.pumpAndSettle();

    expect(find.text('اللغة'), findsWidgets);
    expect(find.text('Language'), findsNothing);
    expect(find.text('عام'), findsWidgets);

    await tester.tap(listed('المظهر'));
    await tester.pumpAndSettle();
    expect(find.text('لون التمييز'), findsOneWidget);
    expect(find.text('Accent color'), findsNothing);
  });

  testWidgets('language menu lists locales and applies Arabic', (tester) async {
    await pumpExampleApp(tester);

    expect(find.byIcon(Icons.language_outlined), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('language_toggle')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('language_menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_ar')), findsOneWidget);
    expect(find.byKey(const ValueKey('language_option_en')), findsOneWidget);

    final menu = tester.getRect(find.byKey(const ValueKey('language_menu')));
    final globe = tester.getRect(find.byKey(const ValueKey('language_toggle')));
    expect(menu.width, 92);
    expect((menu.center.dx - globe.center.dx).abs(), lessThan(1.5));

    await tester.tap(find.byKey(const ValueKey('language_option_ar')));
    await tester.pumpAndSettle();

    expect(find.text('إعدادات'), findsOneWidget);
    await revealText(tester, 'عام');
    expect(listed('عام'), findsOneWidget);
    expect(find.text('Edadat'), findsNothing);

    await openSearch(tester);
    await tester.enterText(searchField, 'theme');
    await tester.pumpAndSettle();
    expect(searchResult('السمة'), findsOneWidget);
  });

  testWidgets('setting editors use Safaeh adaptive surfaces', (tester) async {
    await pumpExampleApp(tester);

    await tester.tap(listed('Language'));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehTilePickerBody<String>), findsOneWidget);
    expect(find.text('Arabic'), findsOneWidget);
    await tester.tap(find.text('Arabic'));
    await tester.pumpAndSettle();

    await revealText(tester, 'الاسم المعروض');
    await tester.tap(listed('الاسم المعروض'));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehTextInputSheet), findsOneWidget);
    expect(find.text('تأكيد'), findsOneWidget);
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehTextInputSheet), findsNothing);
  });

  testWidgets('reset uses the Safaeh confirmation surface', (tester) async {
    await pumpExampleApp(tester);

    await revealText(tester, 'Reset to defaults');
    await tester.ensureVisible(listed('Reset to defaults'));
    await tester.pumpAndSettle();
    await tester.tap(listed('Reset to defaults'));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehConfirmSheet), findsOneWidget);
    expect(find.text('Restore every setting'), findsWidgets);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(SafaehConfirmSheet), findsNothing);
  });

  testWidgets('theme toggle switches light to dark', (tester) async {
    await pumpExampleApp(tester);

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('theme_toggle')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });

  testWidgets('desktop search result opens the section in the detail pane', (
    tester,
  ) async {
    await pumpExampleApp(tester);

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();
    expect(find.text('Select a setting to view details'), findsOneWidget);
    expect(find.text('On this page'), findsOneWidget);

    await openSearch(tester);
    await tester.enterText(searchField, 'theme');
    await tester.pumpAndSettle();
    expect(searchResult('Theme'), findsOneWidget);

    await tester.tap(searchResult('Theme'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(tester.widget<TextField>(searchField).controller?.text, isEmpty);
    expect(find.text('Select a setting to view details'), findsNothing);
    expect(find.byKey(const ValueKey('detail_general')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('detail_general')),
        matching: find.text('Theme'),
      ),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('detail_general')),
        matching: find.text('Light'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile page index jumps to a section', (tester) async {
    await pumpExampleApp(tester);

    final pageIndex = find.byKey(
      const ValueKey('safaeh_settings_page_index_overlay'),
    );
    expect(find.text('On this page'), findsOneWidget);

    await tester.tap(find.text('On this page'));
    await tester.pumpAndSettle();
    final appearance = find.descendant(
      of: pageIndex,
      matching: find.text('Appearance'),
    );
    expect(appearance, findsOneWidget);

    await tester.tap(appearance);
    await tester.pumpAndSettle();
    expect(listed('Accent color'), findsOneWidget);
  });

  testWidgets('wide desktop catalog shows the page index rail', (tester) async {
    await pumpExampleApp(tester);
    tester.view.physicalSize = const Size(1600, 1200);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('layout_toggle')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('safaeh_settings_page_index')),
      findsOneWidget,
    );
    expect(find.text('On this page'), findsOneWidget);
  });
}
