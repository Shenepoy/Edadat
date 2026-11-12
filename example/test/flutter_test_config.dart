import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadScreenshotFonts();
  return testMain();
}

Future<void> loadScreenshotFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final fontsDir = Directory(
      '$flutterRoot/bin/cache/artifacts/material_fonts',
    );
    await _loadFamily(fontsDir, 'Roboto', [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ]);
    await _loadFamily(fontsDir, 'MaterialIcons', ['MaterialIcons-Regular.otf']);
  }

  final bazCandidates = [
    File('assets/fonts/baz-Light.otf'),
    File('../assets/fonts/baz-Light.otf'),
  ];
  for (final file in bazCandidates) {
    if (!file.existsSync()) continue;
    final loader = FontLoader('Baz')
      ..addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)));
    await loader.load();
    break;
  }
}

Future<void> _loadFamily(
  Directory fontsDir,
  String family,
  List<String> fileNames,
) async {
  if (!fontsDir.existsSync()) return;
  final loader = FontLoader(family);
  var added = false;
  for (final name in fileNames) {
    final file = File('${fontsDir.path}/$name');
    if (!file.existsSync()) continue;
    loader.addFont(file.readAsBytes().then((b) => ByteData.view(b.buffer)));
    added = true;
  }
  if (added) await loader.load();
}
