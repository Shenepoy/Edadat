import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:settings_example/app.dart';
import 'package:settings_example/catalog.dart';

const screenshotSize = Size(390, 844);

Future<void> pumpExampleApp(
  WidgetTester tester, {
  String language = 'en',
  String themeMode = 'light',
}) async {
  final storage = MemoryStorage();
  storage.setAll({'language': language, 'theme_mode': themeMode});
  final settings = await bootExampleSettings(storage: storage);

  tester.view.physicalSize = Size(
    screenshotSize.width * 2,
    screenshotSize.height * 2,
  );
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWithValue(settings.controller),
        settingsSearchIndexProvider.overrideWithValue(settings.searchIndex),
        settingsProvidersProvider.overrideWithValue(settings),
      ],
      child: const RepaintBoundary(
        key: ValueKey('screenshot_root'),
        child: ExampleApp(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> saveScreenshot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('screenshot_root')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      fail('Failed to encode $name.png');
    }
    final file = File(_screenshotPath(name));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes.buffer.asUint8List());
  });
}

String _screenshotPath(String name) {
  final testDir = Directory.current.path;
  final root = testDir.endsWith('example')
      ? Directory.current.parent.path
      : testDir;
  return '$root/screenshots/$name.png';
}
