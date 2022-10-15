{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    crane.url = "github:dpc/crane";
    crane.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, flake-compat, fenix, crane }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.android_sdk.accept_license = true;
        };

        lib = pkgs.lib;

        fenix-channel = fenix.packages.${system}.stable;

        fenix-toolchain = with fenix.packages.${system}; combine [
          stable.cargo
          stable.rustc
          targets.aarch64-linux-android.stable.rust-std
          targets.armv7-linux-androideabi.stable.rust-std
          targets.x86_64-linux-android.stable.rust-std
          targets.i686-linux-android.stable.rust-std
        ];

        craneLib = crane.lib.${system}.overrideToolchain fenix-toolchain;

        # Filter only files needed to build project dependencies
        #
        # To get good build times it's vitally important to not have to
        # rebuild derivation needlessly. The way Nix caches things
        # is very simple: if any input file changed, derivation needs to
        # be rebuild.
        #
        # For this reason this filter function strips the `src` from
        # any files that are not relevant to the build.
        #
        # Lile `filterWorkspaceFiles` but doesn't even need *.rs files
        # (because they are not used for building dependencies)
        filterWorkspaceDepsBuildFiles = src: filterSrcWithRegexes [ "Cargo.lock" "Cargo.toml" ".cargo/.*" ".*/Cargo.toml" ] src;

        # Filter only files relevant to building the workspace
        filterWorkspaceFiles = src: filterSrcWithRegexes [ "Cargo.lock" "Cargo.toml" ".cargo/.*" ".*/Cargo.toml" ".*\.rs" ] src;

        filterSrcWithRegexes = regexes: src:
          let
            basePath = toString src + "/";
          in
          lib.cleanSourceWith {
            filter = (path: type:
              let
                relPath = lib.removePrefix basePath (toString path);
                includePath =
                  (type == "directory") ||
                  lib.any
                    (re: builtins.match re relPath != null)
                    regexes;
              in
              # uncomment to debug:
                # builtins.trace "${relPath}: ${lib.boolToString includePath}"
              includePath
            );
            inherit src;
          };


        androidComposition = pkgs.androidenv.composeAndroidPackages {
          includeNDK = true;
        };

        commonArgs = { target }: {
          src = filterWorkspaceFiles ./.;

          cargoExtraArgs = "--target ${target}";

          buildInputs = with pkgs; [
            clang
            gcc
            pkg-config
            openssl
            androidComposition.androidsdk
            fenix-channel.rustc
            fenix-channel.clippy
          ] ++ lib.optionals stdenv.isDarwin [
            libiconv
            darwin.apple_sdk.frameworks.Security
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          preBuild = ''
            chmod +x .cargo/ar.*
            chmod +x .cargo/ld.*
            patchShebangs .cargo
          '';

          LLVM_CONFIG_PATH = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-config";

          CC_armv7_linux_androideabi = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang";
          CXX_armv7_linux_androideabi = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++";
          LD_armv7_linux_androideabi = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld";
          LDFLAGS_armv7_linux_androideabi = "-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/";

          CC_aarch64_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang";
          CXX_aarch64_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++";
          LD_aarch64_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/bin/ld";
          LDFLAGS_aarch64_linux_android = "-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/aarch64-linux-android/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/";

          CC_x86_64_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang";
          CXX_x86_64_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++";
          LD_x86_64_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/bin/ld";
          LDFLAGS_x86_64_linux_android = "-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/x86_64-linux-android/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/";

          CC_i686_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang";
          CXX_i686_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++";
          LD_i686_linux_android = "${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/bin/ld";
          LDFLAGS_i686_linux_android = "-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/i686-linux-android/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/i686-linux-android/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/i686-linux-android/";
        };

        workspaceDeps = { target }: craneLib.buildDepsOnly ((commonArgs { inherit target; }) // {
          src = filterWorkspaceDepsBuildFiles ./.;
          pname = "workspace-deps";
          buildPhaseCargoCommand = "cargo doc --target ${target} && cargo check --target ${target} --profile release --all-targets && cargo build --target ${target} --profile release --all-targets";
          doCheck = false;
        });

        workspaceBuild = { target }: craneLib.buildPackage ((commonArgs { inherit target; }) // {
          pname = "workspace-build";
          cargoArtifacts = workspaceDeps { inherit target; };
          doCheck = false;
        });

        workspaceClippy = { target }: craneLib.cargoClippy ((commonArgs { inherit target; }) // {
          pname = "workspace-clippy";
          cargoArtifacts = workspaceDeps { inherit target; };

          cargoClippyExtraArgs = "--target ${target} --all-targets --no-deps -- --deny warnings";
          doInstallCargoArtifacts = false;
          doCheck = false;
        });

        workspaceDoc = { target }: craneLib.cargoBuild ((commonArgs { inherit target; }) // {
          pname = "workspace-doc";
          cargoArtifacts = workspaceDeps { inherit target; };
          cargoBuildCommand = "env RUSTDOCFLAGS='-D rustdoc::broken_intra_doc_links' cargo doc --target ${target} --no-deps --document-private-items && cp -a target/doc $out";
          doCheck = false;
        });

      in
      {
        packages = builtins.mapAttrs
          (attrName: target: {
            workspaceDeps = workspaceDeps { inherit target; };
            workspaceBuild = workspaceBuild { inherit target; };
            workspaceClippy = workspaceClippy { inherit target; };
            workspaceDoc = workspaceDoc { inherit target; };
          })
          {
            "armv7" = "armv7-linux-androideabi";
            "aarch64" = "aarch64-linux-android";
            "i686" = "i686-linux-android";
            "x86_64" = "x86_64-linux-android";
          };

        devShells =
          {
            # The default shell - meant to developers working on the project,
            # so notably not building any project binaries, but including all
            # the settings and tools neccessary to build and work with the codebase.
            default =
              let
                # note: target here doesn't matter, as long as tools are the same for all target archs

                depsPackage = workspaceDeps { target = "arm-linux-androideabi"; }; in
              pkgs.mkShell {
                stdenv = pkgs.llvmPackages_14.stdenv;
                buildInputs = depsPackage.buildInputs;
                nativeBuildInputs = with pkgs; depsPackage.nativeBuildInputs ++ [
                  fenix-toolchain
                  fenix.packages.${system}.rust-analyzer
                  cargo-udeps

                  nodejs
                  wasm-pack

                  # This is required to prevent a mangled bash shell in nix develop
                  # see: https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
                  (hiPrio pkgs.bashInteractive)

                  # Nix
                  pkgs.nixpkgs-fmt
                  pkgs.shellcheck
                  pkgs.rnix-lsp
                  pkgs.nodePackages.bash-language-server
                ];

                RUST_SRC_PATH = "${fenix-channel.rust-src}/lib/rustlib/src/rust/library";

                shellHook = ''
                  # Note: rockdb seems to require uint128_t, which is not supported on 32-bit Android: https://stackoverflow.com/a/25819240/134409 (?)
                  export LLVM_CONFIG_PATH="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-config"

                  export CC_armv7_linux_androideabi="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang"
                  export CXX_armv7_linux_androideabi="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++"
                  export LD_armv7_linux_androideabi="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/arm-linux-androideabi/bin/ld"
                  export LDFLAGS_armv7_linux_androideabi="-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/arm-linux-androideabi/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/"

                  export CC_aarch64_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang"
                  export CXX_aarch64_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++"
                  export LD_aarch64_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/bin/ld"
                  export LDFLAGS_aarch64_linux_android="-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/aarch64-linux-android/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/"

                  export CC_x86_64_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang"
                  export CXX_x86_64_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++"
                  export LD_x86_64_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/bin/ld"
                  export LDFLAGS_x86_64_linux_android="-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/x86_64-linux-android/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/"

                  export CC_i686_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang"
                  export CXX_i686_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++"
                  export LD_i686_linux_android="${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/aarch64-linux-android/bin/ld"
                  export LDFLAGS_i686_linux_android="-L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/i686-linux-android/30/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/lib/gcc/i686-linux-android/4.9.x/ -L ${androidComposition.ndk-bundle}/libexec/android-sdk/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/i686-linux-android/"
                '';
              };

            # this shell is used only in CI, so it should contain minimum amount
            # of stuff to avoid building and caching things we don't need
            lint = pkgs.mkShell {
              nativeBuildInputs = [
                pkgs.rustfmt
                pkgs.nixpkgs-fmt
                pkgs.shellcheck
                pkgs.git
              ];
            };
          };
      });
}
