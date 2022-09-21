# fluttermint

A Fedimint wallet in Flutter + Rust. DO NOT USE WITH REAL MONEY! This is for tinkering, only.

![Frame 67 (2)](https://user-images.githubusercontent.com/543668/172901667-df3eb020-db13-40b1-8aa5-8041a9782e5a.png)

## Paul's Notes

`just gen` generates the language bindings

If you're following the flutter_rust_bridge guide, you'll want ["Alternative NDK setup"](http://cjycode.com/flutter_rust_bridge/template/setup_android.html?highlight=ndk#alternative-ndk-setup) and compile with rust nightly for now.

## Justin's Notes

- In order to run this on a hardware device and connect to federation running on desktop, you need to turn on "System Preferences > Sharing > Internet Sharing". Turn on all USB-related options.

# Android

When making a release, increment version number and build number in pubspec.yaml: 0.5.1+12 -> 0.5.2+13. Suffix is android build number.

````
$ cat ~/.gradle/gradle.properties
ANDROID_NDK=/Users/justin/Library/Android/sdk/ndk-bundle

Tail logs from terminal:

```
adb logcat | grep -F "`adb shell ps | grep com.justinmoon.fluttermint  | tr -s [:space:] ' ' | cut -d' ' -f2`"
```

## Building for WASM

### Prerequisites

1. [wasm-pack](https://rustwasm.github.io/wasm-pack/)
2. Typescript
3. [dart_js_facade_gen](https://github.com/dart-lang/js_facade_gen)

For debug build:

```sh
just wasm --dev
````

For release build:

```sh
just wasm
```

# Testflight

Build the IPA:

```
flutter build ipa
```

Uploaded it using transport app.

# Play Store

## App Bundle (recommended, but it seems more complex)

```
flutter build appbundle
```

Upload that to google play. [Here](https://docs.flutter.dev/deployment/android#offline-using-the-bundle-tool) are some docs about testing it locally.

# Contributing

Contributions are very welcome, just open an issue or PR if you see something to improve!

Please note that all contributions happen under the MIT license as described below:

```
Developer Certificate of Origin
Version 1.1
Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.
Developer's Certificate of Origin 1.1
By making a contribution to this project, I certify that:
(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or
(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or
(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.
(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```
