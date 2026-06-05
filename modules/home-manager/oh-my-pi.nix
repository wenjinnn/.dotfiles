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
