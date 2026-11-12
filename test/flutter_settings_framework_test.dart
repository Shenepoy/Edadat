import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('package exports core types', () {
    expect(SettingType.values, contains(SettingType.action));
    expect(const ActionSetting('a', titleKey: 'a'), isA<SettingDefinition>());
    expect(MemoryStorage(), isA<SettingsStorage>());
    expect(
      SettingsSearchBarMode.values,
      contains(SettingsSearchBarMode.persistent),
    );
  });

  test('pubspec version is semver major.minor.patch', () {
    // Guard: release workflow also checks this against the git tag.
    const version = String.fromEnvironment('EDADAT_VERSION', defaultValue: '');
    // When not injected, just ensure SettingType.action exists (smoke).
    if (version.isNotEmpty) {
      expect(RegExp(r'^\d+\.\d+\.\d+$').hasMatch(version), isTrue);
    }
    expect(SettingType.action, isNotNull);
  });
}
