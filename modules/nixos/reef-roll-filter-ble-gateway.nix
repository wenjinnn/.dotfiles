{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.reef-roll-filter-ble-gateway;
  serviceName = "reef-roll-filter-ble-gateway";
  serviceUser = serviceName;
  command = lib.concatStringsSep " " [
    "${cfg.package}/bin/${serviceName}"
    "--mode ${lib.escapeShellArg cfg.mode}"
    "--address-file ${lib.escapeShellArg cfg.addressFile}"
    "--name-file ${lib.escapeShellArg cfg.nameFile}"
    "--scan-timeout ${toString cfg.scanTimeout}"
    "--scan-interval ${toString cfg.scanInterval}"
    "--absent-scans ${toString cfg.absentScans}"
    "--recovery-delay ${toString cfg.recoveryDelay}"
    "--recovery-days ${lib.escapeShellArg (lib.concatStringsSep "," (map toString cfg.recoveryDays))}"
    "--recovery-window-start ${lib.escapeShellArg cfg.recoveryWindowStart}"
    "--recovery-window-end ${lib.escapeShellArg cfg.recoveryWindowEnd}"
    "--connect-timeout ${toString cfg.connectTimeout}"
    "--state-file ${lib.escapeShellArg cfg.stateFile}"
    "--notify-timeout ${toString cfg.notifyTimeout}"
    "--mode-check-interval ${toString cfg.modeCheckInterval}"
    "--scheduled-check-time ${lib.escapeShellArg cfg.scheduledCheckTime}"
  ];
in
{
  options.services.reef-roll-filter-ble-gateway = {
    enable = lib.mkEnableOption "reef paper-reel BLE mode restoration";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.reef-roll-filter-ble-gateway;
      description = "Package providing the reef paper-reel BLE gateway.";
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "timer"
        "eco"
        "clean"
      ];
      default = "auto";
      description = "Mode to restore after the paper-reel returns from an outage.";
    };

    addressFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/REEF_ROLL_FILTER_BLE_ADDRESS";
      description = "File containing the private BLE address of the paper-reel device.";
    };

    nameFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/REEF_ROLL_FILTER_BLE_NAME";
      description = "File containing the private BLE local name.";
    };

    scanTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 8;
      description = "Seconds spent scanning during each discovery pass.";
    };

    scanInterval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 10;
      description = "Seconds between discovery passes.";
    };

    absentScans = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3;
      description = "Missed scans required before a device return is treated as recovery.";
    };

    recoveryDelay = lib.mkOption {
      type = lib.types.ints.positive;
      default = 5;
      description = "Seconds to wait after the device returns before connecting and writing.";
    };

    stateFile = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/reef-roll-filter-ble-gateway/state.json";
      description = "Persistent monitor state used to survive service restarts during an outage.";
    };

    recoveryDays = lib.mkOption {
      type = lib.types.listOf (lib.types.ints.between 0 6);
      default = [
        1
        3
        5
      ];
      description = "Weekdays allowed for recovery writes (Monday=0).";
    };

    recoveryWindowStart = lib.mkOption {
      type = lib.types.str;
      default = "19:20";
      description = "Local-time start of the recovery write window (HH:MM).";
    };

    recoveryWindowEnd = lib.mkOption {
      type = lib.types.str;
      default = "19:45";
      description = "Local-time end of the recovery write window (HH:MM).";
    };

    connectTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 15;
      description = "BLE connection timeout in seconds.";
    };

    notifyTimeout = lib.mkOption {
      type = lib.types.ints.positive;
      default = 5;
      description = "Seconds to wait for the matching FFE4 confirmation.";
    };

    modeCheckInterval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3600;
      description = "Seconds between periodic mode checks.";
    };

    scheduledCheckTime = lib.mkOption {
      type = lib.types.str;
      default = "19:32";
      description = "Local time for the scheduled recovery-day mode check (HH:MM).";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    sops.secrets.REEF_ROLL_FILTER_BLE_ADDRESS = {
      owner = serviceUser;
      group = serviceUser;
      mode = "0400";
    };
    sops.secrets.REEF_ROLL_FILTER_BLE_NAME = {
      owner = serviceUser;
      group = serviceUser;
      mode = "0400";
    };

    users.users.${serviceUser} = {
      isSystemUser = true;
      group = serviceUser;
    };
    users.groups.${serviceUser} = { };

    systemd.services.${serviceName} = {
      description = "Restore the reef paper-reel BLE mode after power recovery";
      wantedBy = [ "multi-user.target" ];
      after = [
        "bluetooth.service"
        "network-online.target"
      ];
      wants = [ "bluetooth.service" ];
      serviceConfig = {
        Type = "simple";
        User = serviceUser;
        ExecStart = command;
        Restart = "on-failure";
        RestartSec = 10;
        StateDirectory = serviceName;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
