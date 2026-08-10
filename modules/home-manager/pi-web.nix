# PI WEB browser gateway and persistent session daemon.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.pi-web;
  configFile = "${cfg.homeDirectory}/.config/pi-web/config.json";
  environment = [
    "HOME=${cfg.homeDirectory}"
    "PI_CODING_AGENT_DIR=${cfg.agentDirectory}"
    "PI_WEB_CONFIG=${configFile}"
    "SOPS_SECRETS=${cfg.secretsFile}"
    "PATH=${
      lib.makeBinPath [
        cfg.agentPackage
        pkgs.nodejs
        pkgs.bash
        pkgs.coreutils
        pkgs.git
        pkgs.ripgrep
        pkgs.sops
      ]
    }"
  ];
  service =
    {
      description,
      command,
      after ? [ "network-online.target" ],
      wants ? [ "network-online.target" ],
    }:
    {
      Unit = {
        Description = description;
        After = after;
        Wants = wants;
      };
      Service = {
        ExecStart = "${cfg.package}/bin/${command}";
        Environment = environment;
        WorkingDirectory = cfg.homeDirectory;
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
in
{
  options.services.pi-web = {
    enable = lib.mkEnableOption "PI WEB web gateway and persistent session daemon";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pi-web;
      description = "The PI WEB package to run.";
    };

    agentPackage = lib.mkOption {
      type = lib.types.package;
      default = config.programs.pi-coding-agent.package;
      description = "The Pi Coding Agent package exposed as the pi executable.";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.path;
      default = config.home.homeDirectory;
      description = "Home directory used by the PI WEB user.";
    };

    agentDirectory = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.homeDirectory}/.pi/agent";
      description = "Pi Coding Agent configuration directory.";
    };

    secretsFile = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.homeDirectory}/.dotfiles/secrets.yaml";
      description = "SOPS secrets file exposed to the Pi process.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which PI WEB listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8504;
      description = "PI WEB listening port.";
    };

    allowedPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [
        "${cfg.homeDirectory}/Downloads/paper-adjust"
        "${cfg.homeDirectory}/.dotfiles"
      ];
      description = "Paths that PI WEB may expose to its trusted clients.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.file.".config/pi-web/config.json".text = builtins.toJSON {
      host = cfg.host;
      port = cfg.port;
      spawnSessions = true;
      subsessions = false;
      agent = {
        command = "pi";
        dir = cfg.agentDirectory;
      };
      pathAccess.allowedPaths = cfg.allowedPaths;
    };

    systemd.user.services = {
      pi-web-sessiond = service {
        description = "PI WEB persistent Pi session daemon";
        command = "pi-web-sessiond";
      };

      pi-web = service {
        description = "PI WEB browser gateway";
        command = "pi-web-server";
        after = [
          "network-online.target"
          "pi-web-sessiond.service"
        ];
        wants = [
          "network-online.target"
          "pi-web-sessiond.service"
        ];
      };
    };
  };
}
