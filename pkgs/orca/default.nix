{
  lib,
  desktop ? true,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  fetchurl,
  makeWrapper,
  nodejs_24,
  pnpm_12,
  pnpmConfigHook,
  python3,
  electron ? null,
  file,
  patchelf,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = if desktop then "orca" else "orca-server";
  version = "1.4.256";

  src = fetchFromGitHub {
    owner = "stablyai";
    repo = "orca";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jiVOYV6PXjzGmQnlSyvXXah4lBCPfiXeRgDxaxHPRh8=";
  };

  pinnedNodeHeaders = fetchurl {
    url = "https://nodejs.org/dist/v24.22.1/node-v24.22.1-headers.tar.gz";
    hash = "sha256-Mi4KJ9uQiAk6uDR73Ix+Cqoh3J7VSDkL8Gs5RJTAkmc=";
  };

  pnpmDeps =
    (fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_12;
      fetcherVersion = 4;
      pnpmInstallFlags = [ "--cpu=current,x64,arm64" ];
      hash =
        if desktop then
          "sha256-Hkp2AqSHDXJh6Bzn64S4Yqnh0qTHEFDsct6Pe0H7KX0="
        else
          "sha256-8dKZ6KYqyR4vucar3uO5OBtkiPP79yht6rbsvmd1PLY=";
      fixupPhase = ''
        runHook preFixup

        rm -rf $storePath/{v3,v10,v11}/tmp
        while IFS= read -r -d "" file; do
          if jq empty "$file" >/dev/null 2>&1; then
            jq --sort-keys "del(.. | .checkedAt?)" "$file" | sponge "$file"
          fi
        done < <(find "$storePath" -name "*.json" -print0)

        if [ -f "$storePath/v11/index.db" ]; then
          pnpm-fixup-state-db "$storePath/v11"
          sqlite3 "$storePath/v11/index.db" .dump > "$storePath/v11/index.db.sql"
          rm "$storePath/v11/index.db"
          sed -i "s/,x'/,X'/g" "$storePath/v11/index.db.sql"
        fi

        rm -rf $storePath/{v3,v10,v11}/projects
        find "$storePath" -type f -name "*-exec" -print0 | xargs --no-run-if-empty -0 chmod 555
        find "$storePath" -type f -not -name "*-exec" -print0 | xargs --no-run-if-empty -0 chmod 444
        find "$storePath" -type d -print0 | xargs --no-run-if-empty -0 chmod 555

        (
          cd "$storePath"
          tar --sort=name \
            --mtime="@$SOURCE_DATE_EPOCH" \
            --owner=0 --group=0 --numeric-owner \
            --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
            --zstd -cf "$out/pnpm-store.tar.zst" .
        )

        runHook postFixup
      '';
    }).overrideAttrs
      (_: {
        fixupPhase = ''
          runHook preFixup

          rm -rf $storePath/{v3,v10,v11}/tmp
          while IFS= read -r -d "" file; do
            if jq empty "$file" >/dev/null 2>&1; then
              jq --sort-keys "del(.. | .checkedAt?)" "$file" | sponge "$file"
            fi
          done < <(find "$storePath" -name "*.json" -print0)

          if [ -f "$storePath/v11/index.db" ]; then
            pnpm-fixup-state-db "$storePath/v11"
            sqlite3 "$storePath/v11/index.db" .dump > "$storePath/v11/index.db.sql"
            rm "$storePath/v11/index.db"
            sed -i "s/,x'/,X'/g" "$storePath/v11/index.db.sql"
          fi

          rm -rf $storePath/{v3,v10,v11}/projects
          find "$storePath" -type f \( -path "*/bin/*" -o -name "tsrs" -o -name "esbuild" -o -name "bun" \) -exec chmod 555 {} +
          (
            cd "$storePath"
            tar --sort=name \
              --mtime="@$SOURCE_DATE_EPOCH" \
              --owner=0 --group=0 --numeric-owner \
              --pax-option=exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime \
              --zstd -cf "$out/pnpm-store.tar.zst" .
          )

          runHook postFixup
        '';
      });

  postPatch = ''
    cat > config/scripts/build-identity/build-source-commit.mjs <<'EOF'
    // Nix builds use the immutable GitHub tag source instead of a .git checkout.
    export function resolveBuildSourceCommit() {
      return "6ea47e7342dbf44fb3842c598aaac0be9af76180";
    }
    EOF
  '';

  nativeBuildInputs = [
    nodejs_24
    pnpm_12
    pnpmConfigHook
    python3
    stdenv.cc
    makeWrapper
    file
    patchelf
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    ORCA_CLI_BUILD_COMPILER = "tsrs";
  };

  preBuild = ''
    find -L node_modules -path '*/graphql/NotSupportedTSVersion.d.ts' -delete
    while IFS= read -r -d "" package; do
      node - "$package" <<'NODE'
    import fs from "node:fs";
    const file = process.argv[2];
    const manifest = JSON.parse(fs.readFileSync(file, "utf8"));
    const root = manifest.exports?.["."]?.[0];
    if (root?.import && root?.default) {
      manifest.exports["."][0] = { import: root.import, default: root.default };
      fs.writeFileSync(file, JSON.stringify(manifest, null, 2) + "\n");
    }
    NODE
    done < <(find -L node_modules -path '*/@jridgewell/sourcemap-codec/package.json' -print0)
    while IFS= read -r -d "" binary; do
      if file "$binary" | grep -q "ELF.*executable"; then
        patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" "$binary" || true
      fi
    done < <(find -L node_modules -type f \( -name "tsrs" -o -name "esbuild" -o -name "bun" \) -print0)
  '';

  buildPhase = ''
    runHook preBuild
    # Upstream's full typecheck currently rejects the bundled WebSocket typings under nixpkgs' TS toolchain.
    pnpm run build:wsl-guest
    pnpm run build:cli
    ${lib.optionalString desktop ''
      pnpm run build:electron-vite
      pnpm run verify:built-skills-cli
      pnpm run build:web-from-renderer
    ''}

    native_node_pty="$TMPDIR/orca-node-pty"
    node_headers="$TMPDIR/orca-node-headers"
    node_gyp="$PWD/node_modules/node-gyp/bin/node-gyp.js"
    mkdir -p "$native_node_pty/node_modules" "$node_headers"
    cp -rL node_modules/node-pty "$native_node_pty/node_modules/node-pty"
    cp -rL node_modules/node-addon-api "$native_node_pty/node_modules/node-addon-api"
    tar -xzf ${finalAttrs.pinnedNodeHeaders} --strip-components=1 -C "$node_headers"
    (
      cd "$native_node_pty/node_modules/node-pty"
      ${nodejs_24}/bin/node "$node_gyp" rebuild --nodedir="$node_headers"
    )
    mkdir -p "$native_node_pty/node_modules/node-pty/prebuilds/linux-x64"
    cp "$native_node_pty/node_modules/node-pty/build/Release/pty.node" \
      "$native_node_pty/node_modules/node-pty/prebuilds/linux-x64/pty.node"
    export ORCA_NATIVE_NODE_PTY_DIR="$native_node_pty"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/orca" "$out/bin"
    cp -rL out node_modules package.json resources native "$out/lib/orca/"
    mkdir -p "$out/lib/orca/node_modules/node-pty/prebuilds/linux-x64"
    cp "$ORCA_NATIVE_NODE_PTY_DIR/node_modules/node-pty/prebuilds/linux-x64/pty.node" \
      "$out/lib/orca/node_modules/node-pty/prebuilds/linux-x64/pty.node"
    ${lib.optionalString desktop ''
      printf 'electron' > "$out/lib/orca/node_modules/electron/path.txt"
      mkdir -p "$out/lib/orca/node_modules/electron/dist"
      ln -s ${electron}/bin/electron "$out/lib/orca/node_modules/electron/dist/electron"
    ''}

    makeWrapper ${nodejs_24}/bin/node "$out/bin/orca-ide" \
      --add-flags "$out/lib/orca/out/cli/index.js"
    ${lib.optionalString desktop ''
            makeWrapper ${electron}/bin/electron "$out/bin/orca" \
              --add-flags "$out/lib/orca"
            mkdir -p "$out/share/applications"
            cat > "$out/share/applications/orca.desktop" <<EOF
      [Desktop Entry]
      Name=Orca
      Exec=$out/bin/orca
      Icon=$out/lib/orca/resources/icon.png
      Type=Application
      Terminal=false
      Categories=Development;
      EOF
    ''}
    runHook postInstall
  '';

  meta = {
    description = "Desktop and headless Orca agent workspace built from source";
    homepage = "https://github.com/stablyai/orca";
    license = lib.licenses.mit;
    mainProgram = if desktop then "orca" else "orca-ide";
    platforms = lib.platforms.linux;
  };
})
