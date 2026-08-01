# Wrapper around the nixpkgs jdt-language-server for pi-lens.
#
# pi-lens spawns the Java LSP server as `$JDTLS_PATH` (fallback "jdtls")
# with cwd = the detected project root, and only appends a lombok
# --jvm-arg of its own. The nixpkgs `jdtls` launcher does not read
# JDTLS_JVM_ARGS, so to mirror nvim's after/lsp/jdtls.lua behaviour we
# need a wrapper that injects:
#
#   - --jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false
#     -> never write .classpath/.project/.settings/.factorypath into the
#        project root
#   - -configuration / -data pointing at nvim's jdtls cache
#     ($XDG_CACHE_HOME/nvim/jdtls), so both editors share one workspace
#     index instead of building a second copy under ~/.cache/jdtls
{
  pkgs,
}:
let
  jdtls = pkgs.jdt-language-server;
in
pkgs.writeShellScriptBin "jdtls-pi-lens" ''
  # Same workspace-name scheme as nvim's jdtls.lua:
  #   vim.fn.fnamemodify(root_dir, ':p')  -> absolute path WITH trailing
  #   slash, then every '/' replaced by '_'. pi-lens spawns us with cwd =
  #   the detected project root, so pwd maps 1:1 onto nvim's root_dir.
  root="$(pwd)/"
  ws_name="$(printf '%s' "$root" | tr '/' '_')"
  cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nvim/jdtls"

  exec '${jdtls}/bin/jdtls' \
    --jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false \
    -configuration "$cache/config" \
    -data "$cache/workspace/$ws_name" \
    "$@"
''
