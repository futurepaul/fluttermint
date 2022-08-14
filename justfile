default: gen

wasm *FLAGS:
    wasm-pack build minimint-bridge --target web --out-dir ../web/pkg {{FLAGS}}

    tsc -d web/index.ts --target ES2017
    tsc web/index.ts --target ES2017
    dart_js_facade_gen web/index.d.ts > lib/wasm_generated.dart
    @# needs a manual cast
    sed -i 's/_WasmBridge tt = t/_WasmBridge tt = t as _WasmBridge/' lib/wasm_generated.dart 
    sed -i '/WasmBridge.fakeConstructor$()/d' lib/wasm_generated.dart 

    flutter build web
    @echo "The app is built in build/web"

gen:
    flutter_rust_bridge_codegen \
        -r minimint-bridge/src/api.rs \
        -d lib/bridge_generated.dart \
        -c ios/Runner/bridge_generated.h

