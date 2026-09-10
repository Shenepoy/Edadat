/// Opt-in Safaeh presentation helpers for the settings framework.
///
/// The main package entrypoint intentionally does not export this library.
/// Import it only when the host app wants to use Safaeh's page-index chrome:
///
/// ```dart
/// import 'package:flutter_settings_framework/safaeh.dart';
/// ```
library;

export 'package:safaeh/safaeh.dart'
    show
        SafaehFloatingAppearance,
        SafaehFloatingSurfaceStyle,
        SafaehPageIndex,
        SafaehPageIndexEntry,
        SafaehPageIndexOverlay,
        SafaehTheme,
        SafaehThemeData,
        safaehActivePageSectionId,
        scrollToPageSection;
export 'src/ui/safaeh_page_index.dart';
export 'src/ui/safaeh_search.dart';
