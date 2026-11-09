# Home Manager module for the Paseo daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.paseo;
  settingsFile = (pkgs.formats.json { }).generate "paseo-config.json" cfg.settings;
  serviceEnvironment = {
    PASEO_HOME = cfg.dataDir;
    PASEO_LISTEN = "${cfg.listenAddress}:${toString cfg.port}";
  }
  // lib.optionalAttrs (cfg.hostnames == true) {
    PASEO_HOSTNAMES = "true";
  }
  // lib.optionalAttrs (lib.isList cfg.hostnames && cfg.hostnames != [ ]) {
    PASEO_HOSTNAMES = lib.concatStringsSep "," cfg.hostnames;
  }
  // lib.optionalAttrs (cfg.relay.enable && cfg.relay.mode == "remote") {
    PASEO_RELAY_ENDPOINT = "${cfg.relay.host}:${toString cfg.relay.port}";
    PASEO_RELAY_USE_TLS = if cfg.relay.useTls then "true" else "false";
  }
  //
    lib.optionalAttrs (cfg.relay.enable && cfg.relay.mode == "remote" && cfg.relay.publicUseTls != null)
      {
        PASEO_RELAY_PUBLIC_USE_TLS = if cfg.relay.publicUseTls then "true" else "false";
      }
  // cfg.environment;
  registerHost =
    host:
    let
      endpoint = lib.escapeShellArg host.endpoint;
      label = lib.escapeShellArg host.label;
      passwordSetup = lib.optionalString (host.passwordFile != null) ''
        password="$(${pkgs.coreutils}/bin/tr -d '\n' < ${lib.escapeShellArg host.passwordFile})"
        encoded_password="$(${pkgs.jq}/bin/jq -nr --arg value "$password" '$value | @uri')"
        connection="$endpoint?password=$encoded_password"
      '';
    in
    ''
      label=${label}
      endpoint=${endpoint}
      connection="$endpoint"
      ${passwordSetup}
      hosts="$(${cfg.package}/bin/paseo host ls --json)"
      registration_id="$(${pkgs.jq}/bin/jq -r --arg label "$label" '.[] | select(.label == $label) | .registrationId' <<<"$hosts" | ${pkgs.coreutils}/bin/head -n 1)"

      if [ -n "$registration_id" ]; then
        ${cfg.package}/bin/paseo host update "$registration_id" \
          --label "$label" \
          --connection "$connection"
      else
        ${cfg.package}/bin/paseo host add \
          --label "$label" \
          "$connection"
      fi
    '';
  connectedHostsScript = pkgs.writeShellScript "paseo-connected-hosts" ''
    set -euo pipefail
    ${lib.concatMapStringsSep "\n" registerHost cfg.connectedHosts}
  '';
in
{
  options.services.paseo = {
    enable = lib.mkEnableOption "Paseo, a self-hosted daemon for AI coding agents";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.paseo;
      description = "Paseo package to run.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.home.homeDirectory}/.paseo";
      description = "Directory for Paseo state and configuration.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6767;
      description = "Paseo listening port.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for the Paseo daemon to listen on.";
    };

    hostnames = lib.mkOption {
      type = lib.types.either (lib.types.enum [ true ]) (lib.types.listOf lib.types.str);
      default = [ ];
      description = "Allowed Host header names; true allows any hostname.";
    };

    relay = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Paseo relay access.";
      };

      mode = lib.mkOption {
        type = lib.types.enum [
          "hosted"
          "remote"
        ];
        default = "hosted";
        description = "Relay mode.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Remote relay hostname.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 443;
        description = "Remote relay port.";
      };

      useTls = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use TLS for the remote relay.";
      };

      publicUseTls = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "TLS setting advertised to public clients.";
      };
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional environment variables for Paseo.";
    };

    settings = lib.mkOption {
      type = (pkgs.formats.json { }).type;
      default = { };
      description = "Declarative Paseo config.json settings.";
    };

    connectedHosts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            label = lib.mkOption {
              type = lib.types.str;
              description = "Stable label for the connected Paseo daemon.";
            };
            endpoint = lib.mkOption {
              type = lib.types.str;
              description = "Paseo TCP endpoint, for example tcp://100.64.0.1:6767.";
            };
            passwordFile = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "File containing the remote daemon password.";
            };
          };
        }
      );
      default = [ ];
      description = "Paseo daemons to register with this daemon.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.relay.enable && cfg.relay.mode == "remote" && cfg.relay.host == "");
        message = "services.paseo.relay.host must be set when relay.mode = \"remote\".";
      }
    ];

    home.packages = [ cfg.package ];

    systemd.user.services.paseo = {
      Unit = {
        Description = "Paseo - self-hosted daemon for AI coding agents";
        After = [ "network.target" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/paseo-server${
          lib.optionalString (!cfg.relay.enable) " --no-relay"
        }";
        ExecStartPre = [
          "${pkgs.coreutils}/bin/install -d -m 700 ${lib.escapeShellArg cfg.dataDir}"
        ]
        ++ lib.optional (cfg.settings != { }) (
          "${pkgs.coreutils}/bin/install -m 600 ${settingsFile} "
          + lib.escapeShellArg "${cfg.dataDir}/config.json"
        );
        Environment = lib.mapAttrsToList (name: value: "${name}=${value}") serviceEnvironment;
        WorkingDirectory = cfg.dataDir;
        Restart = "on-failure";
        RestartSec = 5;
        KillSignal = "SIGTERM";
        TimeoutStopSec = 15;
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.paseo-connected-hosts = lib.mkIf (cfg.connectedHosts != [ ]) {
      Unit = {
        Description = "Register connected Paseo daemons";
        Wants = [
          "paseo.service"
          "network-online.target"
        ];
        After = [
          "paseo.service"
          "network-online.target"
        ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = connectedHostsScript;
        Environment = lib.mapAttrsToList (name: value: "${name}=${value}") serviceEnvironment;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
