default: gen

gen:
    flutter_rust_bridge_codegen \
        -r minimint-bridge/src/api.rs \
        -d lib/bridge_generated.dart \
        -c ios/Runner/bridge_generated.h \
        -c macos/Runner/bridge_generated.h

