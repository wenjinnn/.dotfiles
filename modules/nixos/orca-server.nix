{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.orca-server;
  escape = value: lib.escapeShellArg (toString value);
  command = [
    "${pkgs.xvfb-run}/bin/xvfb-run"
    "-a"
    "${cfg.package}/bin/orca-ide"
    "serve"
    "--bind"
    cfg.bindAddress
    "--port"
    cfg.port
    "--pairing-address"
    cfg.pairingAddress
  ]
  ++ cfg.extraArgs;
in
{
  options.services.orca-server = {
    enable = lib.mkEnableOption "the headless Orca server";

    package = lib.mkPackageOption pkgs "orca-server" { };

    pairingAddress = lib.mkOption {
      type = lib.types.str;
      description = "Tailscale hostname or address embedded in Orca pairing links.";
      example = "nixos.ts.example.com";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address on which the Orca runtime accepts connections.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 6768;
      description = "TCP port used by the Orca runtime.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "--refuse-public" ];
      description = "Additional arguments passed to `orca-ide serve`.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "orca";
      description = "User that runs the Orca server.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "orca";
      description = "Group that runs the Orca server.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.${cfg.group} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = "/var/lib/orca";
      createHome = false;
    };

    systemd.services.orca-server = {
      description = "Orca remote workspace server";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = "orca";
        WorkingDirectory = "/var/lib/orca";
        Environment = [
          "HOME=/var/lib/orca"
          "XDG_CONFIG_HOME=/var/lib/orca/.config"
          "XDG_DATA_HOME=/var/lib/orca/.local/share"
          "ORCA_SERVE_RUNTIME=electron"
          "ORCA_APP_EXECUTABLE=${cfg.package}/lib/orca/node_modules/electron/dist/electron"
          "ORCA_APP_EXECUTABLE_NEEDS_APP_ROOT=1"
        ];
        ExecStart = lib.concatMapStringsSep " " escape command;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
