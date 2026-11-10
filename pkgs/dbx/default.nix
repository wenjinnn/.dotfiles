{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nodejs_22,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  cargo-tauri,
  pkg-config,
  perl,
  jq,
  desktop-file-utils,
  copyDesktopItems,
  makeDesktopItem,
  imagemagick,
  wrapGAppsHook3,
  webkitgtk_4_1,
  gtk3,
  libappindicator-gtk3,
  libayatana-appindicator,
  librsvg,
  patchelf,
  openssl,
  glib,
  glib-networking,
  dbus,
  at-spi2-atk,
  atkmm,
  cairo,
  gdk-pixbuf,
  harfbuzz,
  pango,
  xdotool,
  libx11,
  libxext,
  libxfixes,
}:

let
  pname = "dbx";
  version = "0.6.65";
  src = fetchFromGitHub {
    owner = "t8y2";
    repo = "dbx";
    rev = "8e080e9717c08c7e6a3c08ae1fbf34f1847ff034";
    hash = "sha256-e8o79zQhM+Fyb1cfauYb9BMaJeaNu+IEJIwhLkrjm/M=";
  };
  pnpm = pnpm_10;
  pnpmDeps = fetchPnpmDeps {
    inherit
      pname
      version
      src
      pnpm
      ;
    fetcherVersion = 4;
    hash = "sha256-pMa7AX2g0zLlOviY6neTZBMki4JRMR4ffl9NMIf3uSo=";
  };
  desktopItem = makeDesktopItem {
    name = "dbx";
    type = "Application";
    exec = "dbx %u";
    icon = "dbx";
    desktopName = "DBX";
    genericName = "Database Management Tool";
    comment = "Open-source database management tool for 100+ databases";
    categories = [
      "Development"
      "Database"
    ];
    keywords = [
      "database"
      "sql"
      "client"
      "mysql"
      "postgresql"
      "mongodb"
      "redis"
    ];
    startupWMClass = "DBX";
    terminal = false;
    mimeTypes = [
      "application/sql"
      "x-scheme-handler/dbx"
    ];
  };
in
rustPlatform.buildRustPackage {
  inherit
    pname
    version
    src
    pnpmDeps
    ;
  cargoHash = "sha256-qivYZqXBPNh8Dhylk9keIW32dLUI516bAWjV0fKHnNM=";
  doCheck = false;
  CARGO_PROFILE_RELEASE_LTO = "false";
  CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "16";

  nativeBuildInputs = [
    nodejs_22
    pnpm
    pkg-config
    perl
    jq
    cargo-tauri
    pnpmConfigHook
    desktop-file-utils
    copyDesktopItems
    imagemagick
    wrapGAppsHook3
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    libappindicator-gtk3
    libayatana-appindicator
    librsvg
    patchelf
    openssl
    glib
    glib-networking
    dbus
    at-spi2-atk
    atkmm
    cairo
    gdk-pixbuf
    harfbuzz
    pango
    xdotool
    libx11
    libxext
    libxfixes
  ];

  preConfigure = ''
    export HOME="$TMPDIR"
    # nixpkgs forces system crypto libraries, but dbx vendors aws-lc-sys
    # without a compatible system AWS-LC installation.
    export AWS_LC_SYS_USE_SYSTEM=0
    if [ -f package.json ]; then
      jq 'del(.packageManager)' package.json > package.json.tmp
      mv package.json.tmp package.json
    fi
  '';

  buildPhase = ''
    runHook preBuild
    export AWS_LC_SYS_USE_SYSTEM=0
    cargo tauri build --no-bundle
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 target/release/dbx $out/bin/dbx
    install -Dm644 src-tauri/icons/32x32.png \
      $out/share/icons/hicolor/32x32/apps/dbx.png
    install -Dm644 src-tauri/icons/128x128.png \
      $out/share/icons/hicolor/128x128/apps/dbx.png
    install -Dm644 src-tauri/icons/128x128@2x.png \
      $out/share/icons/hicolor/256x256/apps/dbx.png
    for size in 16 48 64; do
      mkdir -p "$out/share/icons/hicolor/''${size}x''${size}/apps"
      if [ "$size" -le 32 ] && [ -f src-tauri/icons/32x32.png ]; then
        icon=src-tauri/icons/32x32.png
      elif [ -f src-tauri/icons/128x128.png ]; then
        icon=src-tauri/icons/128x128.png
      else
        continue
      fi
      magick "$icon" -resize "''${size}x''${size}" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/dbx.png"
    done
    desktop-file-validate ${desktopItem}/share/applications/dbx.desktop
    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = {
    description = "Open-source database management tool built with Tauri, Vue, and Rust";
    homepage = "https://github.com/t8y2/dbx";
    license = lib.licenses.asl20;
    mainProgram = "dbx";
    platforms = lib.platforms.linux;
  };
}
