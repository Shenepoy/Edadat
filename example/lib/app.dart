import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';
import 'package:flutter_settings_framework/safaeh.dart';

import 'appearance_toggles.dart';
import 'catalog.dart';
import 'profile_demo.dart';
import 'theme_ripple.dart';

enum ExamplePreviewLayout { mobile, desktop }

/// Gold-family surfaces with contrast overrides so outline / secondary
/// copy stay readable. Seed still comes from the accent-color setting.
ThemeData catalogTheme(Brightness brightness, Color seed) {
  final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  final scheme = switch (brightness) {
    Brightness.light => base.copyWith(
      onSurface: const Color(0xFF1F1708),
      onSurfaceVariant: const Color(0xFF534A3C),
      outline: const Color(0xFF7A6F5F),
      outlineVariant: const Color(0xFFC9BDAA),
      surface: const Color(0xFFFFF8F0),
      surfaceContainerLow: const Color(0xFFF7EFE3),
      surfaceContainerHigh: const Color(0xFFEDE3D4),
      surfaceContainerHighest: const Color(0xFFE7DCCB),
    ),
    Brightness.dark => base.copyWith(
      onSurface: const Color(0xFFF6EFE2),
      onSurfaceVariant: const Color(0xFFD0C4B4),
      outline: const Color(0xFFA89884),
      outlineVariant: const Color(0xFF5A5146),
      surface: const Color(0xFF16130F),
      surfaceContainerLow: const Color(0xFF221E18),
      surfaceContainerHigh: const Color(0xFF322C24),
      surfaceContainerHighest: const Color(0xFF3C352C),
    ),
  };
  final theme = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Roboto',
    fontFamilyFallback: const ['Baz'],
  );
  return applySafaehMaterialChrome(
    theme,
    colorScheme: scheme,
    textTheme: theme.textTheme,
    dividerColor: scheme.outlineVariant,
    outlineColor: scheme.outline,
    errorColor: scheme.error,
    primarySeed: seed,
    radii: const SafaehMaterialRadii(appBarCenterTitle: false),
  ).copyWith(
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: scheme.onSurface),
    ),
  );
}

class ExampleApp extends ConsumerStatefulWidget {
  const ExampleApp({super.key});

  @override
  ConsumerState<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends ConsumerState<ExampleApp> {
  var _layout = ExamplePreviewLayout.mobile;

  @override
  Widget build(BuildContext context) {
    final language = ref.watchSetting(languageSetting);
    final themeMode = themeModeFor(ref.watchSetting(themeModeSetting));
    final seed = Color(ref.watchSetting(themeColorSetting));
    final textScale = fontScaleFor(ref.watchSetting(fontSizeScaleSetting));

    return SafaehTheme(
      data: const SafaehThemeData(
        tabletBreakpoint: 600,
        desktopBreakpoint: 840,
        dialogMaxWidth: 560,
        contentMaxWidth: 600,
        contentMaxWidthDesktop: 720,
        floatingAppearance: SafaehFloatingAppearance(
          style: SafaehFloatingSurfaceStyle.glass,
        ),
      ),
      child: MaterialApp(
        title: translateExample('app_title', language),
        debugShowCheckedModeBanner: false,
        locale: catalogFlutterLocale(language),
        supportedLocales: [for (final item in catalogLocales) item.locale],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: catalogTheme(Brightness.light, seed),
        darkTheme: catalogTheme(Brightness.dark, seed),
        themeMode: themeMode,
        builder: (context, child) {
          final overlayMode = Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light;
          // Web can restore the view focus during hot restart before the
          // lazy settings list has completed layout. Reading-order focus
          // traversal queries render geometry in that window; widget order
          // keeps restoration deterministic without changing explicit focus.
          return FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: ThemeRippleHost(
                overlay: CatalogAppearanceToggles(
                  localeCode: language,
                  themeMode: overlayMode,
                  isMobileLayout: _layout == ExamplePreviewLayout.mobile,
                  onSelectLocale: (code) =>
                      ref.updateSetting(languageSetting, code),
                  onToggleTheme: () async {
                    final current = ref.readSetting(themeModeSetting);
                    await ref.updateSetting(
                      themeModeSetting,
                      current == 'dark' ? 'light' : 'dark',
                    );
                  },
                  onToggleLayout: () {
                    setState(() {
                      _layout = _layout == ExamplePreviewLayout.mobile
                          ? ExamplePreviewLayout.desktop
                          : ExamplePreviewLayout.mobile;
                    });
                  },
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
        home: ExampleSettingsPage(localeCode: language, layout: _layout),
      ),
    );
  }
}

class ExampleSettingsPage extends ConsumerStatefulWidget {
  const ExampleSettingsPage({
    super.key,
    required this.localeCode,
    required this.layout,
  });

  final String localeCode;
  final ExamplePreviewLayout layout;

  @override
  ConsumerState<ExampleSettingsPage> createState() =>
      _ExampleSettingsPageState();
}

class _ExampleSettingsPageState extends ConsumerState<ExampleSettingsPage> {
  final _settingsPageKey = GlobalKey<RegistrySettingsPageState>();
  final _settingsListKey = GlobalKey();
  final _settingsScrollController = ScrollController();
  late final Map<String, GlobalKey> _sectionKeys;
  String? _activeSectionId;
  var _searchOpen = false;

  @override
  void initState() {
    super.initState();
    final sections = createExampleRegistry().getSortedSections();
    _sectionKeys = {for (final section in sections) section.key: GlobalKey()};
    _activeSectionId = sections.isEmpty ? null : sections.first.key;
    _settingsScrollController.addListener(_updateActiveSection);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActiveSection();
    });
  }

  @override
  void dispose() {
    _settingsScrollController.removeListener(_updateActiveSection);
    _settingsScrollController.dispose();
    super.dispose();
  }

  String t(String key) => translateExample(key, widget.localeCode);

  void _updateActiveSection() {
    if (!mounted) return;
    final context = _settingsListKey.currentContext;
    if (context == null) return;
    final active = activeSafaehSettingsSectionId(
      sections: ref
          .read(settingsProvidersProvider)
          .registry
          .getSortedSections(),
      sectionKeys: _sectionKeys,
      scrollContext: context,
    );
    if (active != null && active != _activeSectionId) {
      setState(() => _activeSectionId = active);
    }
  }

  void _selectSection(SettingSection section) {
    final key = _sectionKeys[section.key];
    if (key == null) return;
    setState(() => _activeSectionId = section.key);
    unawaited(scrollToPageSection(key, controller: _settingsScrollController));
  }

  void _selectSearchResult(SearchResult result) {
    unawaited(
      _settingsPageKey.currentState?.selectSearchResult(result) ??
          Future<void>.value(),
    );
  }

  Widget _buildSearchOverlay(
    SettingsProviders settings,
    SettingsRegistry registry,
  ) {
    return SafaehSettingsSearchOverlay(
      key: const ValueKey('safaeh_settings_search_overlay'),
      isOpen: _searchOpen,
      onClose: () => setState(() => _searchOpen = false),
      searchIndex: settings.searchIndex,
      hintText: t('search_hint'),
      sectionTitleBuilder: (sectionKey) {
        final section = registry.getSection(sectionKey);
        return t(section?.titleKey ?? sectionKey);
      },
      settingTitleBuilder: (setting) => t(setting.titleKey),
      settingSubtitleBuilder: (setting) =>
          setting.subtitleKey == null ? null : t(setting.subtitleKey!),
      emptyMessageBuilder: (query) =>
          t('empty_search').replaceAll('{query}', query),
      showResultSubtitles: true,
      onResultSelected: _selectSearchResult,
    );
  }

  Widget _buildBodyOverlay(
    SettingsProviders settings,
    SettingsRegistry registry,
    bool showPageIndexOverlay,
  ) {
    final sections = registry.getSortedSections();
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showPageIndexOverlay)
          SafaehSettingsPageIndexOverlay(
            key: const ValueKey('safaeh_settings_page_index_overlay'),
            title: t('on_this_page'),
            sections: sections,
            sectionKeys: _sectionKeys,
            labelBuilder: (section) => t(section.titleKey),
            activeId: _activeSectionId,
            onSelect: _selectSection,
          ),
        _buildSearchOverlay(settings, registry),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvidersProvider);
    final registry = settings.registry;
    final tags = ref.watchSetting(tagsSetting);
    final isMobile = widget.layout == ExamplePreviewLayout.mobile;
    final host = MediaQuery.sizeOf(context);
    final showPhoneFrame = isMobile && host.width > 420;
    final showPageIndexRail = !isMobile && host.width >= 720;
    final searchAction = SafaehSettingsSearchButton(
      isOpen: _searchOpen,
      hintText: t('search_hint'),
      onPressed: () => setState(() => _searchOpen = !_searchOpen),
    );
    final sections = registry.getSortedSections();

    final page = RegistrySettingsPage(
      key: _settingsPageKey,
      splitLayout: !isMobile,
      registry: registry,
      settings: settings,
      title: t('app_title'),
      searchHint: t('search_hint'),
      showSearch: false,
      scrollController: _settingsScrollController,
      scrollViewKey: _settingsListKey,
      sectionKeys: _sectionKeys,
      bodyOverlay: _buildBodyOverlay(
        settings,
        registry,
        isMobile || !showPageIndexRail,
      ),
      sectionTitleBuilder: t,
      enumLabelBuilder: t,
      emptySearchMessageBuilder: (query) =>
          t('empty_search').replaceAll('{query}', query),
      emptyDetailMessage: t('empty_detail'),
      tileBuilder: (setting, defaultTile) {
        if (setting is EnumSetting) {
          return Builder(
            builder: (tileContext) =>
                _buildEnumTile(tileContext, ref, settings, setting),
          );
        }
        if (setting is ColorSetting) {
          return Builder(
            builder: (tileContext) => _buildColorTile(
              tileContext,
              ref,
              settings,
              setting,
              defaultTile,
            ),
          );
        }
        if (setting.key == displayNameSetting.key) {
          final value = ref.watchSetting(displayNameSetting);
          return Builder(
            builder: (tileContext) => SettingsTile.fromSetting(
              setting: setting,
              title: t(setting.titleKey),
              subtitle: value,
              onTap: () => _editDisplayName(tileContext, ref, value),
            ),
          );
        }
        if (setting.key == exportSetting.key) {
          return Builder(
            builder: (tileContext) => ActionSettingsTile(
              leading: Icon(setting.icon),
              title: Text(t(setting.titleKey)),
              subtitle: Text(t(setting.subtitleKey!)),
              onTap: () => _export(tileContext, ref),
            ),
          );
        }
        if (setting.key == resetSetting.key) {
          return Builder(
            builder: (tileContext) => ActionSettingsTile(
              leading: Icon(setting.icon),
              title: Text(t(setting.titleKey)),
              subtitle: Text(t(setting.subtitleKey!)),
              isDangerous: true,
              onTap: () => _reset(tileContext, ref),
            ),
          );
        }
        if (setting.key == versionSetting.key) {
          return InfoSettingsTile(
            leading: Icon(setting.icon),
            title: Text(t(setting.titleKey)),
            value: const SafaehLtrText('0.9.0'),
            copyable: true,
            copyValue: '0.9.0',
            copiedMessage: t('copied'),
          );
        }
        if (setting.key == licenseSetting.key) {
          return InfoSettingsTile(
            leading: Icon(setting.icon),
            title: Text(t(setting.titleKey)),
            value: const SafaehLtrText('MPL-2.0'),
            copyable: true,
            copyValue: 'MPL-2.0',
            copiedMessage: t('copied'),
          );
        }
        if (setting.key == openProfileSetting.key) {
          final name = ref.watchSetting(displayNameSetting);
          return Builder(
            builder: (tileContext) => ProfileSettingsCard(
              leading: SafaehGlyphAvatar(letter: name),
              title: Text(name),
              subtitle: SafaehLtrText(t('profile_email')),
              onTap: () => _editDisplayName(tileContext, ref, name),
              actions: [
                ProfileSettingsAction(
                  icon: Icons.edit_outlined,
                  tooltip: t('edit'),
                  onPressed: () => _editDisplayName(tileContext, ref, name),
                ),
              ],
            ),
          );
        }
        return defaultTile;
      },
      sectionContentBuilder: (sectionKey, children) {
        if (sectionKey == 'account') {
          return [...children, ExampleProfileDashboard(translate: t)];
        }
        if (sectionKey != 'data') return children;
        return [
          ...children,
          NavigationSettingsTile(
            leading: Icon(tagsSetting.icon),
            title: Text(t(tagsSetting.titleKey)),
            subtitle: Text(tags.join(' · ')),
          ),
        ];
      },
      actions: [searchAction],
    );

    final pageWithIndex = isMobile || !showPageIndexRail
        ? page
        : Row(
            children: [
              Expanded(child: page),
              SizedBox(
                width: 224,
                child: SafaehSettingsPageIndex(
                  key: const ValueKey('safaeh_settings_page_index'),
                  title: t('on_this_page'),
                  sections: sections,
                  sectionKeys: _sectionKeys,
                  labelBuilder: (section) => t(section.titleKey),
                  activeId: _activeSectionId,
                  onSelect: _selectSection,
                ),
              ),
            ],
          );

    if (!showPhoneFrame) return pageWithIndex;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: FittedBox(child: _PhoneFrame(child: pageWithIndex)),
      ),
    );
  }

  Widget _buildEnumTile(
    BuildContext context,
    WidgetRef ref,
    SettingsProviders settings,
    EnumSetting setting,
  ) {
    final value = ref.watch(settings.provider(setting));
    final enabled = isSettingEnabled(settings, setting, ref);
    String label(String option) {
      if (setting.useRawLabels) return option;
      return t(setting.optionLabels?[option] ?? option);
    }

    return ListTile(
      leading: setting.icon == null ? null : Icon(setting.icon),
      title: Text(t(setting.titleKey)),
      subtitle: Text(label(value)),
      trailing: settingsChevronEnd(context),
      enabled: enabled,
      onTap: enabled
          ? () => _showEnumPicker(context, ref, setting, value, label)
          : null,
    );
  }

  Future<void> _showEnumPicker(
    BuildContext context,
    WidgetRef ref,
    EnumSetting setting,
    String value,
    String Function(String option) label,
  ) async {
    final options = setting.options ?? const <String>[];
    if (options.isEmpty) return;
    final chosen = await showSafaehTilePicker<String>(
      context: context,
      title: t(setting.titleKey),
      selected: value,
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      useRootNavigator: false,
      options: [
        for (final option in options)
          SafaehTileOption(
            value: option,
            label: label(option),
            leading: setting.optionIcons?[option] == null
                ? null
                : Icon(setting.optionIcons![option]),
          ),
      ],
    );
    if (chosen != null && context.mounted) {
      await ref.updateSetting(setting, chosen);
    }
  }

  Widget _buildColorTile(
    BuildContext context,
    WidgetRef ref,
    SettingsProviders settings,
    ColorSetting setting,
    Widget fallback,
  ) {
    final options = setting.colorOptions;
    if (options == null || options.isEmpty) return fallback;

    final value = ref.watch(settings.provider(setting));
    final enabled = isSettingEnabled(settings, setting, ref);
    final theme = Theme.of(context);
    return ListTile(
      leading: setting.icon == null ? null : Icon(setting.icon),
      title: Text(t(setting.titleKey)),
      subtitle: Text(_colorLabel(value)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _colorSwatch(theme, Color(value)),
          const SizedBox(width: 8),
          settingsChevronEnd(context),
        ],
      ),
      enabled: enabled,
      onTap: enabled
          ? () => _showColorPicker(context, ref, setting, value, options)
          : null,
    );
  }

  Future<void> _showColorPicker(
    BuildContext context,
    WidgetRef ref,
    ColorSetting setting,
    int value,
    List<int> options,
  ) async {
    final chosen = await showSafaehTilePicker<int>(
      context: context,
      title: t(setting.titleKey),
      selected: value,
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      useRootNavigator: false,
      options: [
        for (final option in options)
          SafaehTileOption(
            value: option,
            label: _colorLabel(option),
            leading: _colorSwatch(Theme.of(context), Color(option)),
          ),
      ],
    );
    if (chosen != null && context.mounted) {
      await ref.updateSetting(setting, chosen);
    }
  }

  static String _colorLabel(int value) {
    final hex = value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${hex.substring(hex.length - 6)}';
  }

  static Widget _colorSwatch(ThemeData theme, Color color) {
    return SizedBox(
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outline),
        ),
      ),
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final next = await showSafaehTextInput(
      context: context,
      title: t('name_dialog'),
      doneLabel: t('confirm'),
      cancelLabel: t('cancel'),
      initialValue: current,
      maxLength: displayNameSetting.maxLength,
      useRootNavigator: false,
    );
    if (next != null && next.isNotEmpty) {
      await ref.updateSetting(displayNameSetting, next);
    }
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final payload = jsonEncode(ref.settings.controller.exportAll());
    await Clipboard.setData(ClipboardData(text: payload));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('copied'))));
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showSafaehConfirm(
      context: context,
      title: t('reset'),
      content: t('reset_subtitle'),
      confirmLabel: t('confirm'),
      cancelLabel: t('cancel'),
      isDestructive: true,
      dismissReturnsFalse: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      useRootNavigator: false,
    );
    if (confirmed != true || !context.mounted) return;
    await ref.settings.controller.resetAll();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('reset_done'))));
    }
  }
}

class _PhoneFrame extends StatefulWidget {
  const _PhoneFrame({required this.child});

  static const size = Size(390, 844);

  final Widget child;

  @override
  State<_PhoneFrame> createState() => _PhoneFrameState();
}

class _PhoneFrameState extends State<_PhoneFrame> {
  late final ValueNotifier<Widget> _child;

  @override
  void initState() {
    super.initState();
    _child = ValueNotifier(widget.child);
  }

  @override
  void didUpdateWidget(covariant _PhoneFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.child, widget.child)) {
      _child.value = widget.child;
    }
  }

  @override
  void dispose() {
    _child.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('catalog_phone_frame'),
      width: _PhoneFrame.size.width,
      height: _PhoneFrame.size.height,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outline, width: 8),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.24),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            ColoredBox(
              color: scheme.surface,
              child: SizedBox(
                height: 28,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ExcludeSemantics(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          Text(
                            '9:41',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.signal_cellular_alt,
                            size: 14,
                            color: scheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.wifi, size: 14, color: scheme.onSurface),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.battery_full,
                            size: 14,
                            color: scheme.onSurface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(
                    _PhoneFrame.size.width,
                    _PhoneFrame.size.height - 28,
                  ),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                ),
                child: ColoredBox(
                  color: scheme.surface,
                  child: Navigator(
                    key: const ValueKey('catalog_phone_navigator'),
                    onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => ValueListenableBuilder<Widget>(
                        valueListenable: _child,
                        builder: (context, child, _) => child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
