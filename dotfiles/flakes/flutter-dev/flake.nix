{
  description = "Flutter 3.38.9 + Android dev shell (NixOS-safe)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        # ---------- Android SDK ----------
        androidPkgs = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "16.0";

          # Flutter 3.38.x will SDK 36 sehen, BuildTools 28.0.3 ebenfalls.
          platformVersions = [ "29" "34" "36" ];
          buildToolsVersions = [ "28.0.3" ];

          includeEmulator = false;
          includeNDK = false;
          includeSystemImages = false;
          includeSources = false;
          includeExtras = [ ];
        };

        androidSdk = androidPkgs.androidsdk;

        # ---------- Flutter ----------
        flutterVersion = "3.38.9";
        flutterRepo = "https://github.com/flutter/flutter.git";

        flutter = pkgs.writeShellScriptBin "flutter" ''
          set -euo pipefail

          export XDG_CACHE_HOME="$HOME/.cache"
          export PUB_CACHE="$HOME/.pub-cache"
          export FLUTTER_HOME="$HOME/.flutter"

          export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
          export ANDROID_HOME="${androidSdk}/libexec/android-sdk"

          # Erzwinge Nix-Tools fürs Entpacken (Flutter-Subprozesse verlieren gern PATH)
          export PATH="${pkgs.unzip}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.xz}/bin:${pkgs.curl}/bin:$PATH"

          FLUTTER_DIR="$XDG_CACHE_HOME/flutter-sdk/flutter-${flutterVersion}"

          if [ ! -d "$FLUTTER_DIR/.git" ]; then
            mkdir -p "$(dirname "$FLUTTER_DIR")"
            ${pkgs.git}/bin/git clone --depth 1 --branch "${flutterVersion}" \
              "${flutterRepo}" "$FLUTTER_DIR"
          fi

          # --- Extra robust: Tools direkt dahin verlinken, wo Flutter/Dart sie sicher findet ---
          mkdir -p "$FLUTTER_DIR/bin"
          ln -sf "${pkgs.unzip}/bin/unzip" "$FLUTTER_DIR/bin/unzip"
          ln -sf "${pkgs.curl}/bin/curl" "$FLUTTER_DIR/bin/curl" || true

          mkdir -p "$FLUTTER_DIR/bin/cache/dart-sdk/bin"
          ln -sf "${pkgs.unzip}/bin/unzip" "$FLUTTER_DIR/bin/cache/dart-sdk/bin/unzip"
          ln -sf "${pkgs.gnutar}/bin/tar" "$FLUTTER_DIR/bin/cache/dart-sdk/bin/tar" || true
          ln -sf "${pkgs.gzip}/bin/gzip" "$FLUTTER_DIR/bin/cache/dart-sdk/bin/gzip" || true
          ln -sf "${pkgs.xz}/bin/xz" "$FLUTTER_DIR/bin/cache/dart-sdk/bin/xz" || true
          ln -sf "${pkgs.curl}/bin/curl" "$FLUTTER_DIR/bin/cache/dart-sdk/bin/curl" || true

          export FLUTTER_ROOT="$FLUTTER_DIR"
          exec "$FLUTTER_DIR/bin/flutter" "$@"
        '';

        dart = pkgs.writeShellScriptBin "dart" ''
          set -euo pipefail

          export XDG_CACHE_HOME="$HOME/.cache"
          export PUB_CACHE="$HOME/.pub-cache"
          export FLUTTER_HOME="$HOME/.flutter"

          FLUTTER_DIR="$XDG_CACHE_HOME/flutter-sdk/flutter-${flutterVersion}"
          export FLUTTER_ROOT="$FLUTTER_DIR"

          exec "$FLUTTER_DIR/bin/dart" "$@"
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
          ANDROID_HOME = "${androidSdk}/libexec/android-sdk";

          buildInputs = with pkgs; [
            git
            curl
            unzip
            gnutar
            gzip
            xz
            which
            jdk17

            # Android
            androidSdk

            # Linux desktop toolchain
            clang
            cmake
            ninja
            pkg-config

            # GTK / Desktop deps
            gtk3
            glib
            cairo
            pango
            gdk-pixbuf
            atk
            harfbuzz
            fontconfig
            freetype

            # GPU / EGL tools (eglinfo)
            mesa-demos

            # Web
            chromium

            # Flutter wrappers
            flutter
            dart
          ];

          shellHook = ''
            export XDG_CACHE_HOME="$HOME/.cache"
            export PUB_CACHE="$HOME/.pub-cache"
            export FLUTTER_HOME="$HOME/.flutter"

            export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
            export ANDROID_HOME="${androidSdk}/libexec/android-sdk"

            export CHROME_EXECUTABLE="${pkgs.chromium}/bin/chromium"

            # Ganz am ENDE setzen, damit mkShell/buildInputs es nicht "überholen"
            export PATH="${flutter}/bin:${dart}/bin:${pkgs.unzip}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.xz}/bin:$PATH"

            echo "Flutter SDK: $XDG_CACHE_HOME/flutter-sdk/flutter-${flutterVersion}"
            which flutter
            which dart
            which unzip
            which tar
          '';
        };
      });
}

