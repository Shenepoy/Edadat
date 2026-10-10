import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const section = SettingSection(
    key: 'behavior',
    titleKey: 'Behavior',
    initiallyExpanded: true,
  );
  const above = BoolSetting(
    'confirm_delete',
    defaultValue: true,
    titleKey: 'Confirm deletion',
    section: 'behavior',
  );
  const advanced = IntSetting(
    'animation_speed',
    defaultValue: 150,
    titleKey: 'Animation duration',
    section: 'behavior',
    subSection: 'advanced',
  );

  Future<SettingsProviders> settings() {
    return initializeSettings(
      registry: SettingsRegistry.withSettings(
        sections: const [section],
        settings: const [above, advanced],
      ),
      storage: MemoryStorage(),
    );
  }

  testWidgets('advanced groups start collapsed and open downward', (
    tester,
  ) async {
    final providers = await settings();
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: RegistrySettingsPage(
            registry: providers.registry,
            settings: providers,
            subSectionTitleBuilder: (key) =>
                key == 'advanced' ? 'Advanced' : key,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Advanced'), findsOneWidget);
    expect(find.text('Animation duration'), findsNothing);

    final before = tester.getTopLeft(find.text('Confirm deletion')).dy;
    await tester.tap(find.text('Advanced'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      tester.getTopLeft(find.text('Confirm deletion')).dy,
      closeTo(before, 4),
    );
    await tester.pumpAndSettle();
    expect(find.text('Animation duration'), findsOneWidget);
  });

  testWidgets('search opens the subsection before scrolling to the row', (
    tester,
  ) async {
    final providers = await settings();
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWithValue(providers.controller),
          settingsSearchIndexProvider.overrideWithValue(providers.searchIndex),
          settingsProvidersProvider.overrideWithValue(providers),
        ],
        child: MaterialApp(
          home: RegistrySettingsPage(
            registry: providers.registry,
            settings: providers,
            subSectionTitleBuilder: (key) =>
                key == 'advanced' ? 'Advanced' : key,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Animation duration'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Animation');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Behavior › Animation duration'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Animation duration'), findsOneWidget);
  });
}
