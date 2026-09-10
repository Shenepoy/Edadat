import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_settings_framework/safaeh.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Safaeh search keeps clear and close actions separate', (
    tester,
  ) async {
    final index = await _buildSearchIndex();
    final controller = TextEditingController(text: 'dark');
    final focusNode = FocusNode();
    final harnessKey = GlobalKey<_SearchHarnessState>();
    final harness = _SearchHarness(
      key: harnessKey,
      index: index,
      controller: controller,
      focusNode: focusNode,
    );

    await tester.pumpWidget(harness);
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('safaeh_settings_search_clear')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('safaeh_settings_search_clear')),
    );
    await tester.pumpAndSettle();
    expect(controller.text, isEmpty);
    expect(harnessKey.currentState!.open, isTrue);

    controller.text = 'dark';
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('safaeh_settings_search_button')),
    );
    await tester.pumpAndSettle();
    expect(harnessKey.currentState!.open, isFalse);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('safaeh_settings_search_button')),
          )
          .tooltip,
      'Search settings...',
    );

    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('selecting a result closes the overlay and returns the setting', (
    tester,
  ) async {
    final index = await _buildSearchIndex();
    final controller = TextEditingController(text: 'dark');
    final focusNode = FocusNode();
    final harnessKey = GlobalKey<_SearchHarnessState>();
    final harness = _SearchHarness(
      key: harnessKey,
      index: index,
      controller: controller,
      focusNode: focusNode,
    );

    await tester.pumpWidget(harness);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();

    expect(harnessKey.currentState!.open, isFalse);
    expect(harnessKey.currentState!.selectedKey, 'dark_mode');

    controller.dispose();
    focusNode.dispose();
  });
}

Future<SearchIndex> _buildSearchIndex() async {
  final registry = SettingsRegistry.withSettings(
    sections: const [SettingSection(key: 'appearance', titleKey: 'appearance')],
    settings: const [
      BoolSetting(
        'dark_mode',
        defaultValue: false,
        titleKey: 'dark_mode',
        section: 'appearance',
      ),
    ],
  );
  final index = SearchIndex(registry: registry);
  await index.build();
  return index;
}

class _SearchHarness extends StatefulWidget {
  const _SearchHarness({
    super.key,
    required this.index,
    required this.controller,
    required this.focusNode,
  });

  final SearchIndex index;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_SearchHarness> createState() => _SearchHarnessState();
}

class _SearchHarnessState extends State<_SearchHarness> {
  bool open = true;
  String? selectedKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            SafaehSettingsSearchButton(
              isOpen: open,
              onPressed: () => setState(() => open = !open),
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const SizedBox.shrink(),
            SafaehSettingsSearchOverlay(
              isOpen: open,
              onClose: () => setState(() => open = false),
              searchIndex: widget.index,
              controller: widget.controller,
              focusNode: widget.focusNode,
              sectionTitleBuilder: (_) => 'Appearance',
              settingTitleBuilder: (_) => 'Dark mode',
              onResultSelected: (result) =>
                  setState(() => selectedKey = result.setting.key),
            ),
          ],
        ),
      ),
    );
  }
}
