# oh-my-pi (omp) home-manager module
# Docs: https://omp.sh/docs
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.oh-my-pi;
  yamlFmt = pkgs.formats.yaml { };

  derivations = lib.filter lib.isDerivation cfg.extraPackages;
in
{
  options.programs.oh-my-pi = {
    enable = lib.mkEnableOption "oh-my-pi (omp) coding agent";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.oh-my-pi;
      defaultText = lib.literalExpression "pkgs.oh-my-pi";
      description = "The omp package to use.";
    };

    settings = lib.mkOption {
      type = yamlFmt.type;
      default = { };
      description = ''
        Attrs written to ~/.omp/agent/config.yml.
        See <https://omp.sh/docs/settings>.
      '';
    };

    customProviders = lib.mkOption {
      type = yamlFmt.type;
      default = { };
      description = ''
        Provider definitions written to ~/.omp/agent/models.yml.
        See <https://omp.sh/docs/custom-models>.
      '';
    };

    mcpServers = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        MCP server definitions written to ~/.omp/agent/mcp.json.
        See <https://omp.sh/docs/mcp>.
      '';
    };

    keybindings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Keybinding overrides written to ~/.omp/agent/keybindings.json.
        See <https://omp.sh/docs/keybindings>.
      '';
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        Environment variables written to ~/.omp/.env.
        See <https://omp.sh/docs/env>.
      '';
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        Pi packages as Nix derivations to install declaratively.
        These are linked to ~/.omp/npm/lib/node_modules/ for omp to discover.
        Use pkgs.nur.repos.wenjinnn.piPackages.* or pkgs.piPackages.* to reference available packages.
      '';
    };

    preLaunchHook = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Shell commands to run before launching omp (inside the wrapper).
        Useful for injecting sops-managed secrets.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "omp" ''
        ${cfg.preLaunchHook}
        exec ${cfg.package}/bin/omp "$@"
      '')
    ];

    home.shellAliases = {
      "omp-reset-config" =
        "rm -f $HOME/.omp/agent/config.yml && echo 'Config reset. Next omp launch will re-seed from nix config.'";
    };

    home.activation.omp-plugins-link = lib.mkIf (derivations != []) (
      let
        pluginsDir = "$HOME/.omp/plugins";
        linkCommands = map (drv: ''
          if [ -f "${drv}/package.json" ]; then
            pkg_name=$(${pkgs.nodejs}/bin/node -e "console.log(JSON.parse(require('fs').readFileSync('${drv}/package.json', 'utf8')).name)")
            if [ -n "$pkg_name" ]; then
              if [[ "$pkg_name" == @* ]]; then
                scope="''${pkg_name%%/*}"
                name="''${pkg_name#*/}"
                mkdir -p "${pluginsDir}/node_modules/$scope"
                ln -sfn "${drv}" "${pluginsDir}/node_modules/$scope/$name"
              else
                mkdir -p "${pluginsDir}/node_modules"
                ln -sfn "${drv}" "${pluginsDir}/node_modules/$pkg_name"
              fi
              # Accumulate dependency entries for package.json
              echo "$pkg_name" >> "${pluginsDir}/.nix-deps"
            fi
          fi
        '') derivations;
        # Build package.json with all deps pointing to "link:" (already symlinked)
        genPkgJson = ''
          if [ -f "${pluginsDir}/.nix-deps" ]; then
            deps=""
            while IFS= read -r dep; do
              [ -n "$deps" ] && deps="$deps,"
              deps="$deps\"$dep\":\"link:$dep\"";
            done < "${pluginsDir}/.nix-deps"
            printf '{"name":"omp-plugins","private":true,"dependencies":{%s}}\n' "$deps" \
              > "${pluginsDir}/package.json"
            rm -f "${pluginsDir}/.nix-deps"
          fi
        '';
      in
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "${pluginsDir}/node_modules"
        ${lib.concatStringsSep "\n" linkCommands}
        ${genPkgJson}
      ''
    );

    home.file = {
      ".omp/agent/config.yml" = lib.mkIf (cfg.settings != { }) {
        source = yamlFmt.generate "omp-config.yml" cfg.settings;
      };

      ".omp/agent/models.yml" = lib.mkIf (cfg.customProviders != { }) {
        source = yamlFmt.generate "omp-models.yml" cfg.customProviders;
      };

      ".omp/agent/mcp.json" = lib.mkIf (cfg.mcpServers != { }) {
        text = builtins.toJSON {
          "$schema" =
            "https://raw.githubusercontent.com/can1357/oh-my-pi/main/packages/coding-agent/src/config/mcp-schema.json";
          mcpServers = cfg.mcpServers;
        };
      };

      ".omp/agent/keybindings.yml" = lib.mkIf (cfg.keybindings != { }) {
        source = yamlFmt.generate "omp-keybindings.yml" cfg.keybindings;
      };

      ".omp/.env" = lib.mkIf (cfg.env != { }) {
        text = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") cfg.env) + "\n";
      };
    };
  };
}
