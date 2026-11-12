// Enable Wasm on all supported engines; Flutter keeps the JS fallback.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    wasmAllowList: { blink: true, webkit: true, gecko: true },
  },
});
