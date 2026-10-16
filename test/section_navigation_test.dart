import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('latest pending section request wins after expansion', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    final visited = <String>[];
    final navigation = SettingsSectionNavigation();
    addTearDown(navigation.dispose);
    navigation.layoutChanged();
    final first = navigation.navigate(() async => visited.add('first'));
    await tester.pump(const Duration(milliseconds: 16));
    final second = navigation.navigate(() async => visited.add('second'));
    expect(navigation.isNavigating, isTrue);
    await tester.pump(const Duration(milliseconds: 230));
    await tester.pump();
    await Future.wait([first, second]);
    expect(visited, ['second']);
    expect(navigation.isNavigating, isFalse);
  });

  testWidgets('manual cancellation and disposal prevent stale jumps', (
    tester,
  ) async {
    await tester.pumpWidget(const SizedBox());
    var jumps = 0;
    final navigation = SettingsSectionNavigation();
    navigation.layoutChanged();
    final pending = navigation.navigate(() async => jumps++);
    navigation.cancel();
    await tester.pump(const Duration(milliseconds: 250));
    await pending;
    expect(jumps, 0);
    navigation.layoutChanged();
    final disposed = navigation.navigate(() async => jumps++);
    navigation.dispose();
    await tester.pump(const Duration(milliseconds: 250));
    await disposed;
    expect(jumps, 0);
  });

  testWidgets('distant anchors are measurable before scrolling', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final target = GlobalKey();
    final navigation = SettingsSectionNavigation();
    addTearDown(navigation.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsSectionList(
            controller: controller,
            navigation: navigation,
            children: [
              const SizedBox(height: 2000),
              SizedBox(key: target, height: 100, child: const Text('Target')),
            ],
          ),
        ),
      ),
    );
    expect(target.currentContext, isNotNull);
    expect(controller.offset, 0);
    navigation.layoutChanged();
    final pending = navigation.navigate(() async => fail('drag must cancel'));
    await tester.drag(find.byType(ListView), const Offset(0, -100));
    await tester.pump(const Duration(milliseconds: 250));
    await pending;
    expect(navigation.isNavigating, isFalse);
    expect(tester.takeException(), isNull);
  });
}
