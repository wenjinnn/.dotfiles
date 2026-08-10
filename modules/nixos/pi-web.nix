# PI WEB as a NixOS-managed per-user service.
{
  config,
  inputs,
  lib,
  me,
  pkgs,
  ...
}:
let
  cfg = config.services.pi-web;
  environment = [
    "HOME=${cfg.homeDirectory}"
    "PI_CODING_AGENT_DIR=${cfg.agentDirectory}"
    "PI_WEB_CONFIG=/etc/pi-web/config.json"
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
  service = command: {
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${cfg.package}/bin/${command}";
      Environment = environment;
      WorkingDirectory = cfg.homeDirectory;
      Restart = "on-failure";
      RestartSec = 5;
    };
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
      default = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
      description = "The Pi Coding Agent package exposed as the pi executable.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = me.username;
      description = "User account that owns the PI WEB sessions.";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/home/${me.username}";
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
      description = "Address on which PI WEB listens. Keep loopback when using SSH forwarding.";
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
    assertions = [
      {
        assertion = builtins.hasAttr cfg.user config.users.users;
        message = "services.pi-web.user must name an existing NixOS user.";
      }
    ];

    environment.etc."pi-web/config.json".text = builtins.toJSON {
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

    environment.systemPackages = [
      cfg.agentPackage
      cfg.package
    ];

    users.manageLingering = true;
    users.users.${cfg.user}.linger = true;

    systemd.user.services = {
      pi-web-sessiond = {
        description = "PI WEB persistent Pi session daemon";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      }
      // service "pi-web-sessiond";

      pi-web = {
        description = "PI WEB browser gateway";
        after = [
          "network-online.target"
          "pi-web-sessiond.service"
        ];
        wants = [
          "network-online.target"
          "pi-web-sessiond.service"
        ];
      }
      // service "pi-web-server";
    };
  };
}
