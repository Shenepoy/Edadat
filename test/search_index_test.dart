import 'package:material_ui/material_ui.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SettingsRegistry registry;
  late PreIndexedLocalizationProvider localization;

  setUp(() {
    const appearance = SettingSection(
      key: 'appearance',
      titleKey: 'appearance',
      icon: Icons.palette,
    );
    const about = SettingSection(
      key: 'about',
      titleKey: 'about',
      icon: Icons.info,
    );

    final theme = EnumSetting(
      'theme_mode',
      defaultValue: 'system',
      titleKey: 'theme',
      subtitleKey: 'theme_description',
      options: const ['system', 'light', 'dark'],
      section: 'appearance',
      searchTerms: const {
        'en': ['dark', 'light', 'mode'],
        'ar': ['داكن', 'فاتح'],
      },
    );

    final language = EnumSetting(
      'language',
      defaultValue: 'en',
      titleKey: 'language',
      options: const ['en', 'ar'],
      section: 'appearance',
      searchTerms: const {
        'en': ['locale'],
        'ar': ['لغة'],
      },
    );

    final hidden = BoolSetting(
      'internal_flag',
      defaultValue: false,
      titleKey: 'internal_flag',
      section: 'appearance',
      visible: false,
    );

    final displayName = StringSetting(
      'display_name',
      defaultValue: 'Ada',
      titleKey: 'display_name',
      section: 'about',
      searchTerms: const {
        'en': ['name', 'profile'],
        'ar': ['اسم', 'ملف'],
      },
    );

    final exportAction = ActionSetting(
      'action_export',
      titleKey: 'export_data',
      subtitleKey: 'export_data_description',
      section: 'about',
      icon: Icons.upload,
      searchTerms: const {
        'en': ['backup', 'download'],
        'ar': ['تصدير'],
      },
    );

    registry = SettingsRegistry.withSettings(
      sections: const [appearance, about],
      settings: [theme, language, hidden, displayName, exportAction],
    );

    localization = PreIndexedLocalizationProvider({
      'en': {
        'appearance': 'Appearance',
        'about': 'About',
        'theme': 'Theme',
        'theme_description': 'Light or dark mode',
        'language': 'Language',
        'export_data': 'Export data',
        'export_data_description': 'Save a backup file',
        'internal_flag': 'Internal',
        'display_name': 'Display name',
      },
      'ar': {
        'appearance': 'المظهر',
        'about': 'حول',
        'theme': 'السمة',
        'theme_description': 'وضع فاتح أو داكن',
        'language': 'اللغة',
        'export_data': 'تصدير البيانات',
        'export_data_description': 'حفظ ملف نسخ احتياطي',
        'internal_flag': 'داخلي',
        'display_name': 'الاسم المعروض',
      },
    });
  });

  test('matches across locales regardless of query language', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final arTheme = index.search('داكن');
    expect(arTheme.map((r) => r.setting.key), contains('theme_mode'));
    expect(
      arTheme.firstWhere((r) => r.setting.key == 'theme_mode').matchedLocale,
      'ar',
    );

    final enTheme = index.search('theme');
    expect(enTheme.map((r) => r.setting.key), contains('theme_mode'));

    final arLanguage = index.search('لغة');
    expect(arLanguage.map((r) => r.setting.key), contains('language'));
  });

  test('indexes section titles onto settings in that section', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final byEnSection = index.search('appearance');
    expect(byEnSection.map((r) => r.setting.key), contains('theme_mode'));
    expect(byEnSection.map((r) => r.setting.key), contains('language'));

    final byArSection = index.search('المظهر');
    expect(byArSection.map((r) => r.setting.key), contains('theme_mode'));
  });

  test('multi-word queries require all words', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final hit = index.search('dark mode');
    expect(hit.map((r) => r.setting.key), contains('theme_mode'));

    final miss = index.search('dark xylophone');
    expect(miss, isEmpty);
  });

  test('excludes invisible settings from results', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final results = index.search('internal');
    expect(results, isEmpty);

    // Term is indexed but filtered at search time
    expect(index.getTermsForSetting('internal_flag'), isNotEmpty);
  });

  test('indexes ActionSetting entries', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final byTitle = index.search('export');
    expect(byTitle.map((r) => r.setting.key), contains('action_export'));
    expect(byTitle.first.setting, isA<ActionSetting>());

    final bySynonym = index.search('backup');
    expect(bySynonym.map((r) => r.setting.key), contains('action_export'));

    final byAr = index.search('تصدير');
    expect(byAr.map((r) => r.setting.key), contains('action_export'));
  });

  test('Arabic queries do not fuzzy-match unrelated titles', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    final keys = index.search('مظهر').map((r) => r.setting.key);
    expect(keys, contains('theme_mode'));
    expect(keys, isNot(contains('display_name')));
  });

  test('Arabic search ignores tatweel, harakat, and alef variants', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    // السمة with tatweel after س
    expect(
      index.search('الســمة').map((r) => r.setting.key),
      contains('theme_mode'),
    );
    // ألمظهر (alef with hamza) vs المظهر
    expect(
      index.search('ألمظهر').map((r) => r.setting.key),
      contains('theme_mode'),
    );
    expect(normalizeSearchText('الســمة'), normalizeSearchText('السمة'));
    expect(normalizeSearchText('ألمظهر'), normalizeSearchText('المظهر'));
  });

  test('Latin typos of 4+ letters still match', () async {
    final index = SearchIndex(
      registry: registry,
      localizationProvider: localization,
    );
    await index.build();

    expect(
      index.search('thme').map((r) => r.setting.key),
      contains('theme_mode'),
    );
    expect(index.search('xyzq'), isEmpty);
  });
}
