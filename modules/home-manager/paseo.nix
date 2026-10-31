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
  // lib.optionalAttrs (
    cfg.relay.enable
    && cfg.relay.mode == "remote"
    && cfg.relay.publicUseTls != null
  ) {
    PASEO_RELAY_PUBLIC_USE_TLS = if cfg.relay.publicUseTls then "true" else "false";
  }
  // cfg.environment;
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
        type = lib.types.enum [ "hosted" "remote" ];
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
        ExecStart = "${cfg.package}/bin/paseo-server${lib.optionalString (!cfg.relay.enable) " --no-relay"}";
        ExecStartPre = [
          "${pkgs.coreutils}/bin/install -d -m 700 ${lib.escapeShellArg cfg.dataDir}"
        ] ++ lib.optional (cfg.settings != { }) (
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
  };
}
