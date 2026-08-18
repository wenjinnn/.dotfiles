# QMD - on-device hybrid search for markdown files (BM25 + vector + LLM rerank)
# https://github.com/tobi/qmd
#
# Adapted from the upstream flake.nix (MIT): bun install (production deps) into a
# fixed-output derivation, node-gyp rebuild for better-sqlite3, then wrap
# `bun src/cli/qmd.ts` with sqlite on LD_LIBRARY_PATH.
{ pkgs, lib }:

let
  version = "2.8.3";
  src = pkgs.fetchFromGitHub {
    owner = "tobi";
    repo = "qmd";
    rev = "facd35e01359e59d938bc9418e93fb9318addee3"; # v2.8.3
    hash = "sha256-/7Z94r/9rXqzKlz/YkB6/nToSCPamV4Dnxm8EhelTDo=";
  };

  # node_modules via bun install (production only, no scripts run)
  nodeModules = pkgs.stdenvNoCC.mkDerivation {
    pname = "qmd-node-modules";
    inherit version src;

    nativeBuildInputs = [ pkgs.bun ];

    dontConfigure = true;

    buildPhase = ''
      export HOME=$(mktemp -d)

      bun install \
        --backend copyfile \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --production
    '';

    installPhase = ''
      mkdir -p $out
      cp -R node_modules $out/
    '';

    dontFixup = true;

    # x86_64-linux hash from the upstream flake.nix (re-verify on bump;
    # a mismatch reports the correct `got:` value)
    outputHash = "sha256-jvq2TO0SxEV1BHyT6C32VQ916wMTM/D1nsV2rNcJQSo=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "qmd";
  inherit version src;

  nativeBuildInputs = [
    pkgs.bun
    pkgs.makeWrapper
    pkgs.nodejs
    pkgs.node-gyp
    pkgs.python3 # node-gyp needs a Python to build better-sqlite3
  ];

  buildInputs = [ pkgs.sqlite ];

  buildPhase = ''
    export HOME=$(mktemp -d)

    cp -R ${nodeModules}/node_modules ./
    chmod -R u+w node_modules

    (cd node_modules/better-sqlite3 && node-gyp rebuild --release)
  '';

  installPhase = ''
    mkdir -p $out/lib/qmd
    mkdir -p $out/bin

    cp -r node_modules $out/lib/qmd/
    cp -r src $out/lib/qmd/
    cp -r skills $out/lib/qmd/
    cp package.json $out/lib/qmd/

    # Wrap `bun src/cli/qmd.ts` directly (upstream approach, mirrors bin/qmd):
    # quiet llama/ggml native logs for `qmd mcp` (stdio is JSON-RPC), and
    # disable Metal residency sets on Darwin so ggml's process-static
    # destructor does not dump a stack trace after a successful query.
    makeWrapper ${pkgs.bun}/bin/bun $out/bin/qmd \
      --add-flags "$out/lib/qmd/src/cli/qmd.ts" \
      --set DYLD_LIBRARY_PATH "${pkgs.sqlite.out}/lib" \
      --set LD_LIBRARY_PATH "${pkgs.sqlite.out}/lib${lib.optionalString pkgs.stdenv.hostPlatform.isLinux ":${pkgs.stdenv.cc.libc.out}/lib:${pkgs.stdenv.cc.cc.lib}/lib"}" \
      --run 'if [ "$1" = mcp ]; then export LLAMA_LOG_LEVEL="''${LLAMA_LOG_LEVEL:-error}"; export GGML_LOG_LEVEL="''${GGML_LOG_LEVEL:-error}"; export GGML_BACKEND_SILENT="''${GGML_BACKEND_SILENT:-1}"; fi; if [ "$(uname -s)" = Darwin ] && [ "''${QMD_METAL_KEEP_RESIDENCY:-}" != 1 ]; then export GGML_METAL_NO_RESIDENCY="''${GGML_METAL_NO_RESIDENCY:-1}"; fi'
  '';

  meta = with lib; {
    description = "On-device search engine for markdown notes, meeting transcripts, and knowledge bases";
    homepage = "https://github.com/tobi/qmd";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
