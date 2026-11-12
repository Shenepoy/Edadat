import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:settings_example/theme_ripple.dart';

void main() {
  test('reveal radius reaches the farthest corner', () {
    expect(
      themeRevealRadius(const Size(100, 40), Offset.zero),
      math.sqrt(100 * 100 + 40 * 40),
    );
    expect(
      themeRevealRadius(const Size(100, 40), const Offset(100, 40)),
      math.sqrt(100 * 100 + 40 * 40),
    );
    expect(
      themeRevealRadius(const Size(80, 80), const Offset(40, 40)),
      40 * math.sqrt(2),
    );
  });

  test('clipper punches a hole at the origin', () {
    const clipper = ThemeRevealClipper(origin: Offset(10, 10), radius: 8);
    final path = clipper.getClip(const Size(100, 100));

    expect(path.contains(const Offset(10, 10)), isFalse);
    expect(path.contains(const Offset(90, 90)), isTrue);
  });

  testWidgets('apply still runs when there is no host', (tester) async {
    var applied = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => ThemeRipple.apply(
              context,
              () async => applied = true,
              nextMode: ThemeMode.dark,
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(applied, isTrue);
  });

  testWidgets('busy host still applies a second change', (tester) async {
    var applied = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ThemeRippleHost(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => ThemeRipple.apply(
                context,
                () async => applied++,
                nextMode: ThemeMode.dark,
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(applied, 2);
  });

  testWidgets('fadeLocale still runs when there is no host', (tester) async {
    var applied = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                ThemeRipple.fadeLocale(context, () async => applied = true),
            child: const Text('go'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(applied, isTrue);
  });
}
