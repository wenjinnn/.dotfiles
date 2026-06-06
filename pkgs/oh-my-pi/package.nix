{
  lib,
  stdenvNoCC,
  rustPlatform,
  bun,
  fetchFromGitHub,
  makeBinaryWrapper,
  ripgrep,
  fd,
  writableTmpDirAsHomeHook,
}:

let
  version = "15.9.1";

  src = fetchFromGitHub {
    owner = "can1357";
    repo = "oh-my-pi";
    tag = "v${version}";
    hash = "sha256-WrTbC+b51a3J3OnMv8YYr+VS3A3D7SYmf6qOtBCRahs=";
  };

  # ── Step 1: Fixed-output derivation for bun dependencies ──────────────────
  node_modules = stdenvNoCC.mkDerivation {
    pname = "oh-my-pi-node_modules";
    inherit version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -R node_modules $out/

      runHook postInstall
    '';

    dontFixup = true;

    outputHash = "sha256-jaQq2nWsFIvk4OtNTCauqYXwFbq7l61p8x4IolOV5QA=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  # ── Step 2: Build the Rust NAPI native module ─────────────────────────────
  pi-natives = rustPlatform.buildRustPackage {
    pname = "oh-my-pi-pi-natives";
    inherit version src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    cargoBuildFlags = [
      "--package"
      "pi-natives"
    ];
    doCheck = false;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib
      # cdylib output with --target goes to target/<triple>/release/
      local libpath
      for p in \
        target/x86_64-unknown-linux-gnu/release/libpi_natives.so \
        target/release/libpi_natives.so; do
        if [ -f "$p" ]; then libpath="$p"; break; fi
      done
      if [ -z "$libpath" ]; then
        echo "ERROR: libpi_natives.so not found" >&2
        find target -name 'libpi_natives*' >&2 || true
        exit 1
      fi
      # NAPI addon: JS loader expects pi_natives.<platform>-<arch>.node
      cp "$libpath" $out/lib/pi_natives.linux-x64-gnu.node

      runHook postInstall
    '';

    meta = {
      description = "Native Rust bindings for oh-my-pi";
      license = lib.licenses.mit;
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "oh-my-pi";
  inherit version src;

  nativeBuildInputs = [
    bun
    makeBinaryWrapper
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    # Copy fetched node_modules into the source tree
    cp -R ${node_modules}/node_modules .
    chmod -R u+w node_modules
    patchShebangs node_modules 2>/dev/null || true

    # Copy the pre-built native module
    mkdir -p packages/natives/native
    cp ${pi-natives}/lib/pi_natives.linux-x64-gnu.node packages/natives/native/
    # The loader also checks for -modern/-baseline variants and plain linux-x64
    ln -sf pi_natives.linux-x64-gnu.node packages/natives/native/pi_natives.linux-x64.node
    ln -sf pi_natives.linux-x64-gnu.node packages/natives/native/pi_natives.linux-x64-modern.node
    ln -sf pi_natives.linux-x64-gnu.node packages/natives/native/pi_natives.linux-x64-baseline.node

    runHook postConfigure
  '';

  buildPhase = ''
        runHook preBuild

        # ── Patch: relax Bun version check (nixpkgs has 1.3.13, omp wants 1.3.14)
        substituteInPlace packages/utils/package.json \
          --replace-fail '"bun": ">=1.3.14"' '"bun": ">=1.3.13"' || true
        substituteInPlace packages/coding-agent/package.json \
          --replace-fail '"bun": ">=1.3.14"' '"bun": ">=1.3.13"' || true

        # ── Generate docs index (reads docs/ → emits docs-index.generated.ts) ──
        bun packages/coding-agent/scripts/generate-docs-index.ts

        # ── Generate placeholder for embedded stats client bundle ───────────
        mkdir -p packages/stats/src
        echo 'export const EMBEDDED_CLIENT_ARCHIVE_TAR_GZ_BASE64 = "";' \
          > packages/stats/src/embedded-client.generated.txt

        # ── Create placeholder for embedded native addon ────────────────────
        echo 'export const embeddedAddon = null;' \
          > packages/natives/native/embedded-addon.js

        # ── Build the compiled binary ───────────────────────────────────────
        mkdir -p packages/coding-agent/dist

        bun build \
          --compile \
          --no-compile-autoload-bunfig \
          --no-compile-autoload-dotenv \
          --no-compile-autoload-tsconfig \
          --no-compile-autoload-package-json \
          --keep-names \
          --define 'process.env.PI_COMPILED="true"' \
          --define 'process.env.PI_TINY_TRANSFORMERS_VERSION="0.0.0"' \
          --external mupdf \
          --root . \
          --outfile packages/coding-agent/dist/omp \
          packages/coding-agent/src/cli.ts \
          packages/stats/src/sync-worker.ts \
          packages/coding-agent/src/tools/browser/tab-worker-entry.ts \
          packages/coding-agent/src/eval/js/worker-entry.ts \
          packages/agent/src/index.ts \
          packages/natives/native/index.js \
          packages/tui/src/index.ts \
          packages/utils/src/index.ts \
          packages/coding-agent/src/extensibility/typebox.ts \
          packages/coding-agent/src/extensibility/legacy-pi-ai-shim.ts \
          packages/coding-agent/src/extensibility/legacy-pi-coding-agent-shim.ts

        # ── Generate shell completions from source ─────────────────────────────
        cat > gen-completions.ts << 'GENEOF'
    import { buildSpec, generateCompletion } from "./packages/coding-agent/src/cli/completion-gen.ts";
    import { commands } from "./packages/coding-agent/src/cli-commands.ts";
    import { APP_NAME, VERSION } from "./packages/utils/src/dirs.ts";

    const ROOT_COMMAND = "launch";
    const loaded = await Promise.all(commands.map(async entry => ({ entry, Cmd: await entry.load() })));
    const map = new Map();
    const aliasMap = new Map();
    for (const { entry, Cmd } of loaded) {
      map.set(entry.name, Cmd);
      const merged = new Set([...(Cmd.aliases ?? []), ...(entry.aliases ?? [])]);
      aliasMap.set(entry.name, [...merged]);
    }
    const config = { bin: APP_NAME, version: VERSION, commands: map };
    const spec = buildSpec(config, ROOT_COMMAND, aliasMap);
    const fs = await import("node:fs");
    const out = process.argv[2];
    fs.mkdirSync(out + "/share/bash-completion/completions", { recursive: true });
    fs.mkdirSync(out + "/share/zsh/site-functions", { recursive: true });
    fs.mkdirSync(out + "/share/fish/vendor_completions.d", { recursive: true });
    fs.writeFileSync(out + "/share/bash-completion/completions/omp", generateCompletion("bash", spec));
    fs.writeFileSync(out + "/share/zsh/site-functions/_omp", generateCompletion("zsh", spec));
    fs.writeFileSync(out + "/share/fish/vendor_completions.d/omp.fish", generateCompletion("fish", spec));
    console.log("Generated completions for bash, zsh, fish");
    GENEOF

        bun gen-completions.ts "$out"
        rm -f gen-completions.ts

        runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 packages/coding-agent/dist/omp $out/bin/omp

    # Install native addon alongside the binary so it can be found at runtime
    install -Dm644 packages/natives/native/pi_natives.linux-x64-gnu.node $out/bin/pi_natives.linux-x64-gnu.node
    ln -sf pi_natives.linux-x64-gnu.node $out/bin/pi_natives.linux-x64.node
    ln -sf pi_natives.linux-x64-gnu.node $out/bin/pi_natives.linux-x64-modern.node
    ln -sf pi_natives.linux-x64-gnu.node $out/bin/pi_natives.linux-x64-baseline.node

    wrapProgram $out/bin/omp \
      --prefix PATH : ${
        lib.makeBinPath [
          ripgrep
          fd
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Fork of Pi coding agent with IDE integration, native grep, LSP, DAP, and more";
    homepage = "https://omp.sh/";
    downloadPage = "https://www.npmjs.com/package/@oh-my-pi/pi-coding-agent";
    changelog = "https://github.com/can1357/oh-my-pi/blob/v${version}/packages/coding-agent/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "omp";
  };
}
