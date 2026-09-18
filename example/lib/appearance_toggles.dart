import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'catalog.dart';
import 'theme_ripple.dart';

/// Fukaha language menu: 92px, flag + short code, centered on the globe.
const double _kLanguageMenuWidth = 92;
const double _kToggleSize = 44;
const double _kMenuGap = 4;
const double _kSearchActionInset = 52;

const Duration _kMenuIn = Duration(milliseconds: 180);
const Duration _kMenuOut = Duration(milliseconds: 120);
const Duration _kGlobeSwivel = Duration(milliseconds: 640);

/// Language menu + light/dark.
///
/// Lives in [MaterialApp.builder] **above** the navigator so catalog scroll
/// cannot steal taps. That layer has no [Overlay], so this menu is a local
/// [Column] under the globe (not `showMenu` / [CompositedTransformFollower]).
class CatalogAppearanceToggles extends StatefulWidget {
  const CatalogAppearanceToggles({
    super.key,
    required this.localeCode,
    required this.themeMode,
    required this.isMobileLayout,
    required this.onSelectLocale,
    required this.onToggleTheme,
    required this.onToggleLayout,
  });

  final String localeCode;
  final ThemeMode themeMode;
  final bool isMobileLayout;
  final Future<void> Function(String code) onSelectLocale;
  final Future<void> Function() onToggleTheme;
  final VoidCallback onToggleLayout;

  @override
  State<CatalogAppearanceToggles> createState() =>
      _CatalogAppearanceTogglesState();
}

class _CatalogAppearanceTogglesState extends State<CatalogAppearanceToggles>
    with TickerProviderStateMixin {
  var _wantMenu = false;
  var _themePunching = false;
  final _languageToggle = GlobalKey();
  final _themeToggle = GlobalKey();
  late final AnimationController _menu;
  late final Animation<double> _menuFade;
  late final Animation<double> _menuScale;
  late final Animation<Offset> _menuSlide;
  late final AnimationController _themeScale;
  late final AnimationController _globe;
  late final Animation<double> _globeTurn;
  late final Animation<double> _globeScale;

  @override
  void initState() {
    super.initState();
    _menu = AnimationController(
      vsync: this,
      duration: _kMenuIn,
      reverseDuration: _kMenuOut,
    );
    final menuCurve = CurvedAnimation(parent: _menu, curve: kLanguageMotion);
    _menuFade = menuCurve;
    _menuScale = Tween<double>(begin: 0.96, end: 1).animate(menuCurve);
    _menuSlide = Tween<Offset>(
      begin: const Offset(0, -0.04),
      end: Offset.zero,
    ).animate(menuCurve);
    _themeScale = AnimationController(
      vsync: this,
      value: 1,
      lowerBound: 0.82,
      upperBound: 1,
    );
    _globe = AnimationController(vsync: this, duration: _kGlobeSwivel);
    final globeCurve = CurvedAnimation(
      parent: _globe,
      curve: Curves.easeInOutCubic,
    );
    _globeTurn = Tween<double>(begin: 0, end: 1).animate(globeCurve);
    _globeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.84), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.84, end: 1.08), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1), weight: 1),
    ]).animate(globeCurve);
  }

  @override
  void dispose() {
    _menu.dispose();
    _themeScale.dispose();
    _globe.dispose();
    super.dispose();
  }

  bool get _showMenu => _wantMenu || _menu.isAnimating || _menu.value > 0;

  Offset? _originOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  Future<void> _setMenuOpen(bool open) async {
    if (_wantMenu == open && !_menu.isAnimating) return;
    _wantMenu = open;
    if (open) {
      if (mounted) setState(() {});
      await _menu.forward();
    } else {
      await _menu.reverse();
      if (mounted) setState(() {});
    }
  }

  Future<void> _prepareLocale(String code) async {
    await warmupCatalogLocale(
      code,
      style: Theme.of(context).textTheme.bodyLarge,
    );
    for (var i = 0; i < 3; i++) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) return;
    }
    if (_globe.isAnimating) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
  }

  Future<void> _selectLocale(String code) async {
    await _setMenuOpen(false);
    if (!mounted || code == widget.localeCode) return;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (!reduce) {
      unawaited(
        _globe.forward(from: 0).whenComplete(() {
          if (mounted) _globe.value = 0;
        }),
      );
    }
    await ThemeRipple.apply(
      context,
      () => widget.onSelectLocale(code),
      origin: _originOf(_languageToggle),
      prepare: reduce ? null : () => _prepareLocale(code),
    );
  }

  Future<void> _cycleTheme() async {
    if (_themePunching) return;
    _themePunching = true;
    unawaited(_setMenuOpen(false));
    try {
      await _themeScale.animateTo(
        0.82,
        duration: const Duration(milliseconds: 120),
      );
      if (!mounted) return;
      final next = widget.themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
      unawaited(
        ThemeRipple.apply(
          context,
          widget.onToggleTheme,
          nextMode: next,
          origin: _originOf(_themeToggle),
        ),
      );
      await _themeScale.animateTo(
        1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.fastOutSlowIn,
      );
    } finally {
      _themePunching = false;
      if (mounted) _themeScale.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = widget.themeMode == ThemeMode.dark;
    final dir = Directionality.of(context);
    String t(String key) => translateCatalog(key, widget.localeCode);
    final buttonStyle = IconButton.styleFrom(
      foregroundColor: cs.onSurface,
      minimumSize: const Size(_kToggleSize, _kToggleSize),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
    final themeLabel =
        '${t('theme')}: ${dark ? t('theme_dark') : t('theme_light')}';
    final layoutLabel = widget.isMobileLayout
        ? t('layout_desktop')
        : t('layout_mobile');

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_showMenu)
          Positioned.fill(
            child: GestureDetector(
              key: const ValueKey('language_menu_dismiss'),
              behavior: HitTestBehavior.opaque,
              onTap: () => _setMenuOpen(false),
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
        Positioned.directional(
          textDirection: dir,
          top: 0,
          // Keep the app-bar search action at the true trailing edge. The
          // demo controls live just to its leading side on narrow screens.
          end: _kSearchActionInset,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 4, top: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Material(
                    color: cs.surfaceContainerHighest,
                    elevation: 3,
                    shadowColor: cs.shadow.withValues(alpha: 0.32),
                    shape: StadiumBorder(side: BorderSide(color: cs.outline)),
                    clipBehavior: Clip.antiAlias,
                    child: IconTheme(
                      data: IconThemeData(color: cs.onSurface, size: 22),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            button: true,
                            label: layoutLabel,
                            child: IconButton(
                              key: const ValueKey('layout_toggle'),
                              style: buttonStyle,
                              onPressed: () {
                                unawaited(_setMenuOpen(false));
                                widget.onToggleLayout();
                              },
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                switchInCurve: Curves.fastOutSlowIn,
                                switchOutCurve: Curves.fastOutSlowIn,
                                child: Icon(
                                  widget.isMobileLayout
                                      ? Icons.desktop_windows_outlined
                                      : Icons.smartphone,
                                  key: ValueKey(widget.isMobileLayout),
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: t('language'),
                            child: KeyedSubtree(
                              key: _languageToggle,
                              child: IconButton(
                                key: const ValueKey('language_toggle'),
                                style: buttonStyle,
                                onPressed: () => _setMenuOpen(!_wantMenu),
                                icon: AnimatedBuilder(
                                  animation: _globe,
                                  builder: (context, child) {
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.002)
                                        ..rotateY(
                                          _globeTurn.value * math.pi * 2,
                                        )
                                        ..scaleByDouble(
                                          _globeScale.value,
                                          _globeScale.value,
                                          _globeScale.value,
                                          1,
                                        ),
                                      child: child,
                                    );
                                  },
                                  child: const Icon(Icons.language_outlined),
                                ),
                              ),
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: themeLabel,
                            child: KeyedSubtree(
                              key: _themeToggle,
                              child: IconButton(
                                key: const ValueKey('theme_toggle'),
                                style: buttonStyle,
                                onPressed: _cycleTheme,
                                icon: ScaleTransition(
                                  scale: _themeScale,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 440),
                                    switchInCurve: Curves.fastOutSlowIn,
                                    switchOutCurve: Curves.fastOutSlowIn,
                                    child: Icon(
                                      dark
                                          ? Icons.dark_mode_outlined
                                          : Icons.light_mode_outlined,
                                      key: ValueKey(widget.themeMode),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showMenu) ...[
                    const SizedBox(height: _kMenuGap),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end:
                            _kToggleSize +
                            (_kToggleSize - _kLanguageMenuWidth) / 2,
                      ),
                      child: FadeTransition(
                        opacity: _menuFade,
                        child: SlideTransition(
                          position: _menuSlide,
                          child: ScaleTransition(
                            alignment: Alignment.topCenter,
                            scale: _menuScale,
                            child: _LanguageMenu(
                              selectedCode: widget.localeCode,
                              onSelect: _selectLocale,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu({required this.selectedCode, required this.onSelect});

  final String selectedCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selectedFill = Color.lerp(
      cs.surfaceContainerLow,
      cs.primaryContainer,
      0.28,
    )!;
    return Material(
      key: const ValueKey('language_menu'),
      color: cs.surfaceContainerHigh,
      elevation: 3,
      shadowColor: cs.shadow.withValues(alpha: 0.32),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: _kLanguageMenuWidth,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final locale in catalogLocales)
                _LanguageMenuItem(
                  locale: locale,
                  selected: locale.code == selectedCode,
                  selectedFill: selectedFill,
                  onSelect: onSelect,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  const _LanguageMenuItem({
    required this.locale,
    required this.selected,
    required this.selectedFill,
    required this.onSelect,
  });

  final CatalogLocale locale;
  final bool selected;
  final Color selectedFill;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final duration = reduce ? Duration.zero : const Duration(milliseconds: 160);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.fastOutSlowIn,
        decoration: BoxDecoration(
          color: selected ? selectedFill : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          key: ValueKey('language_option_${locale.code}'),
          onTap: () => onSelect(locale.code),
          borderRadius: BorderRadius.circular(8),
          child: Semantics(
            button: true,
            selected: selected,
            label: locale.label,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        locale.flag,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: duration,
                        curve: Curves.fastOutSlowIn,
                        style:
                            theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: selected ? cs.primary : cs.onSurface,
                            ) ??
                            TextStyle(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: selected ? cs.primary : cs.onSurface,
                            ),
                        child: Text(locale.shortCode),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
