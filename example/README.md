# Settings Framework Example

Bilingual `RegistrySettingsPage` catalog for `flutter_settings_framework`
(definitions, Riverpod wiring, tiles, EN/AR search, `dependsOn`), with Safaeh's
“On this page” index and glass search overlay wired into the host app.
Language and theme toggles sit above the catalog (same chrome as Safaeh), and
setting pickers, text input, confirmations, info sheets, and the sessions
panel use Safaeh 0.5's adaptive surfaces and list/status chrome.

Live: [zyzto.github.io/Edadat](https://zyzto.github.io/Edadat/)

`web/` is in-tree for GitHub Pages. A green [CI](../.github/workflows/ci.yml)
run on `main` builds `example/` (`flutter build web --release --base-href /Edadat/`)
and deploys that site. **Run workflow** on CI republishes the same path.
Other platforms are not generated, so `flutter run` on a device needs
`flutter create .` first.

## Analyze

```bash
cd example
flutter pub get
dart analyze --fatal-infos
```

## Tests and screenshots

```bash
cd example
flutter test
```

`test/screenshots_test.dart` renders the catalog and writes PNGs to
[`../screenshots/`](../screenshots/) for the package READMEs. CI runs that
test and uploads the PNGs as the `screenshots` artifact.

## Web

```bash
cd example
flutter pub get
flutter build web --release --base-href /Edadat/
```

## Run on a device (optional)

Generate the other platforms first, then run:

```bash
cd example
flutter create . --project-name settings_example --platforms=android,ios
flutter pub get
flutter run
```

## What it shows

1. **Setting definitions** — Bool, Enum, Color, Double, Int, String, StringList, Action
2. **Registry** — sections + settings, including `dependsOn`
3. **Initialization** — Riverpod overrides via `initializeSettings` + `PreIndexedLocalizationProvider`
4. **UI** — `RegistrySettingsPage` tiles, info/action rows, and host overlays
5. **Search** — Safaeh's glass search overlay with English and Arabic terms
6. **Reactive updates** — language, theme mode, and accent color drive `MaterialApp`
7. **Layout toggle** — app-bar switch between mobile catalog and desktop split view
8. **On this page** — Safaeh page-index overlay on mobile and rail on desktop
9. **Language + theme toggles** — overlay chrome with circular theme reveal
10. **Adaptive Safaeh surfaces** — pickers, text input, confirmations, info sheets, and the sessions sheet
