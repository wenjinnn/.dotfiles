# Declarative per-plugin configuration for pi-coding-agent extensions.
#
# The upstream home-manager `programs.pi-coding-agent` module only manages
# `settings.json` / `keybindings.json` / `models.json` / `AGENTS.md`.
# Individual plugins keep their own config files which pi never touches
# declaratively, e.g.:
#
#   - pi-web-access            -> $PI_CODING_AGENT_DIR/web-search.json
#                                 or $XDG_CONFIG_HOME/pi/web-search.json
#                                 or ~/.pi/web-search.json
#                                 (runtime resolution in the plugin's utils.ts)
#   - pi-permission-system     -> <configDir>/extensions/pi-permission-system/config.json
#   - any other package        -> <configDir>/extensions/<name>/config.json
#   - pi-subagents agents      -> <configDir>/agents/<name>.md
#
# This module lets you declare those files in Nix. Because most plugins
# *write* their own config at runtime (settings modals, /web-search
# toggles, onboarding state), the default `mode = "copy"` copies the
# store-managed config over the live file on every activation: the file
# stays writable, and the next `home-manager switch` re-syncs it to the
# declared values. Use `mode = "symlink"` only for plugins whose config is
# strictly read-only.
#
# pi-subagents agent files (`agents`) are markdown (frontmatter + system
# prompt), so the default is inverted: `mode = "symlink"` (read-only,
# fully declarative) since agents are static by nature; use `copy` if some
# tool rewrites the live file at runtime.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.programs.pi-coding-agent;
  plugins = cfg.plugins;
  agents = cfg.agents;
  jsonFormat = pkgs.formats.json { };

  upstreamConfigDir = "${config.home.homeDirectory}/.pi/agent";

  # Mirror pi-web-access's runtime resolution (utils.ts):
  #   PI_CODING_AGENT_DIR > $XDG_CONFIG_HOME/pi > ~/.pi
  # PI_CODING_AGENT_DIR is only exported by the upstream module when
  # configDir differs from the upstream default.
  piWebAccessPath = "${cfg.configDir}/web-search.json";

  pluginPath =
    name: p:
    if p.path != null then
      p.path
    else if name == "pi-web-access" then
      piWebAccessPath
    else
      "${cfg.configDir or upstreamConfigDir}/extensions/${name}/config.json";

  generate = name: p: jsonFormat.generate "pi-plugin-${name}" p.config;

  # Store path for an agent's markdown content; `source` wins over `text`.
  agentSource =
    name: a: if a.source != null then a.source else pkgs.writeText "pi-agent-${name}.md" a.text;

  agentPath = name: "${cfg.configDir or upstreamConfigDir}/agents/${name}.md";

  symlinkPlugins = lib.filterAttrs (_: p: p.mode == "symlink") plugins;
  copyPlugins = lib.filterAttrs (_: p: p.mode == "copy") plugins;
  symlinkAgents = lib.filterAttrs (_: a: a.mode == "symlink") agents;
  copyAgents = lib.filterAttrs (_: a: a.mode == "copy") agents;
in
{
  options.programs.pi-coding-agent.plugins = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          config = mkOption {
            type = jsonFormat.type;
            default = { };
            description = ''
              Config content written to the plugin's config file.

              Provider API-key fields of pi-web-access accept credential
              sources instead of raw keys: `$NAME` reads one environment
              variable, `!command` runs a trusted local command at request
              time (use this with sops so secrets never enter the nix
              store). Example:

              ```nix
              config = {
                workflow = "auto-summary";
                geminiApiKey = "!${lib.getExe pkgs.sops} exec-env <secrets> 'echo -n $GEMINI_API_KEY'";
              };
              ```
            '';
          };

          path = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = ''
              Override the config file location. Defaults to the plugin's
              conventional location (pi-web-access resolves
              `web-search.json` per its runtime rules; every other plugin
              uses `<configDir>/extensions/<name>/config.json`).
            '';
          };

          mode = mkOption {
            type = types.enum [
              "copy"
              "symlink"
            ];
            default = "copy";
            description = ''
              - `copy` (default): on every home-manager activation the
                declared config is copied over the live file, which stays
                writable for runtime toggles until the next rebuild
                re-syncs it. Use this for plugins that write their own
                config (pi-web-access, pi-permission-system, ...).

              - `symlink`: link the file directly into the nix store
                (read-only). Fully declarative, but any runtime write by
                the plugin fails.
            '';
          };
        };
      }
    );
    default = { };
    example = {
      "pi-web-access" = {
        config = {
          workflow = "auto-summary";
          searxngBaseUrl = "http://localhost:8080";
        };
      };
      "pi-permission-system" = {
        config = {
          yoloMode = false;
          permission = {
            "*" = "allow";
            bash = {
              "*" = "allow";
              "rm -rf *" = "ask";
              "sudo *" = "ask";
              "git push *" = "ask";
            };
          };
        };
      };
    };
    description = ''
      Declarative configuration for individual pi-coding-agent plugins.
      Each attribute name is the plugin/package id; its `config` is
      written to the plugin's config file on every activation.
    '';
  };

  options.programs.pi-coding-agent.agents = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          source = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = ''
              Path to the agent's markdown file (YAML frontmatter + system
              prompt). Preferred over `text` for maintainability.
            '';
          };

          text = mkOption {
            type = types.str;
            default = "";
            description = ''
              Inline agent markdown content when no `source` is given.
            '';
          };

          mode = mkOption {
            type = types.enum [
              "copy"
              "symlink"
            ];
            default = "symlink";
            description = ''
              - `symlink` (default): link the agent file directly into the
                nix store (read-only). Fully declarative; agents are
                static by nature.

              - `copy`: on every home-manager activation the declared
                content is copied over the live file, which stays
                writable for tools that rewrite the file at runtime
                (e.g. pi-goal-list-loop-audit).
            '';
          };
        };
      }
    );
    default = { };
    example = {
      "vision" = {
        source = ./agents/vision.md;
      };
    };
    description = ''
      Declarative pi-subagents agent files, written to
      `<configDir>/agents/<name>.md` (user-scope discovery). Each
      attribute name is the agent id; the file must carry `name` and
      `description` in its frontmatter for pi-subagents to load it.
    '';
  };

  config = mkIf (cfg.enable or false) {
    home.file = lib.mkMerge [
      (mkIf (symlinkPlugins != { }) (
        lib.mapAttrs' (
          name: p:
          lib.nameValuePair "pi-plugin-${name}" {
            target = pluginPath name p;
            source = generate name p;
          }
        ) symlinkPlugins
      ))

      (mkIf (symlinkAgents != { }) (
        lib.mapAttrs' (
          name: a:
          lib.nameValuePair "pi-agent-${name}" {
            target = agentPath name;
            source = agentSource name a;
          }
        ) symlinkAgents
      ))
    ];

    home.activation.piPluginConfigs = mkIf (copyPlugins != { }) (
      lib.hm.dag.entryAfter [ "linkGeneration" ] (
        lib.concatMapStringsSep "\n" (
          name:
          let
            p = copyPlugins.${name};
            path = pluginPath name p;
          in
          ''
            mkdir -p "$(dirname '${path}')"
            cp -f '${generate name p}' '${path}'
          ''
        ) (lib.attrNames copyPlugins)
      )
    );

    home.activation.piAgentConfigs = mkIf (copyAgents != { }) (
      lib.hm.dag.entryAfter [ "linkGeneration" ] (
        lib.concatMapStringsSep "\n" (
          name:
          let
            a = copyAgents.${name};
            path = agentPath name;
          in
          ''
            mkdir -p "$(dirname '${path}')"
            cp -f '${agentSource name a}' '${path}'
          ''
        ) (lib.attrNames copyAgents)
      )
    );
  };
}
