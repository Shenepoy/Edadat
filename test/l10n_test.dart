import 'package:material_ui/material_ui.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Material end chevron mirrors via matchTextDirection', () {
    expect(Icons.chevron_right.matchTextDirection, isTrue);
    expect(Icons.chevron_left.matchTextDirection, isTrue);
  });

  testWidgets('settingsChevronEnd keeps the LTR glyph in Arabic', (
    tester,
  ) async {
    IconData? ltr;
    IconData? rtl;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ltr = settingsChevronEnd(context).icon;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) {
              rtl = settingsChevronEnd(context).icon;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(ltr, Icons.chevron_right);
    expect(rtl, Icons.chevron_right);
  });
}
