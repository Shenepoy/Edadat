import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_settings_framework/safaeh.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps keyed Edadat sections to Safaeh entries', () {
    final appearance = const SettingSection(
      key: 'appearance',
      titleKey: 'appearance',
      icon: Icons.palette_outlined,
    );
    final hidden = const SettingSection(key: 'hidden', titleKey: 'hidden');
    final appearanceKey = GlobalKey();

    final entries = safaehSettingsPageIndexEntries(
      sections: [appearance, hidden],
      sectionKeys: {'appearance': appearanceKey},
      labelBuilder: (section) => 'Label: ${section.titleKey}',
    );

    expect(entries, hasLength(1));
    expect(entries.single.id, 'appearance');
    expect(entries.single.label, 'Label: appearance');
    expect(entries.single.key, same(appearanceKey));
    expect(entries.single.icon, Icons.palette_outlined);
  });

  testWidgets('renders the explicit Safaeh settings page index', (
    tester,
  ) async {
    final section = const SettingSection(key: 'general', titleKey: 'general');
    final key = GlobalKey();
    SettingSection? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafaehSettingsPageIndex(
            title: 'On this page',
            sections: [section],
            sectionKeys: {'general': key},
            labelBuilder: (value) => value.titleKey,
            activeId: 'general',
            onSelect: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('On this page'), findsOneWidget);
    expect(find.text('general'), findsOneWidget);
    await tester.tap(find.text('general'));
    expect(selected, same(section));
  });
}
