import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

import 'app.dart';
import 'catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = await bootExampleSettings();

  runApp(
    ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWithValue(settings.controller),
        settingsSearchIndexProvider.overrideWithValue(settings.searchIndex),
        settingsProvidersProvider.overrideWithValue(settings),
      ],
      child: const ExampleApp(),
    ),
  );
}
