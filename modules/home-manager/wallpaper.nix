{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.wallpaper-switch
  ];
  # custom wallpaper services
  systemd.user = {
    services = {
      wallpaper-get = {
        Unit = {
          Description = "Download wallpaper (rotating: bing/nasa/yande/wallhaven)";
          After = "graphical-session.target";
          Conflicts = "wallpaper-random.service";
        };
        Service = {
          Type = "oneshot";
          Environment = [
            "HOME=${config.home.homeDirectory}"
            "NASA_API_KEY="
          ];
          ExecStartPre = "${pkgs.bash}/bin/bash -c 'systemctl --user import-environment XDG_CURRENT_DESKTOP'";
          ExecStart = "${pkgs.wallpaper-get}/bin/wallpaper-get";
          KillMode = "process";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
      wallpaper-random = {
        Unit = {
          Description = "switch random wallpaper";
          After = "graphical-session.target";
          PartOf = "graphical-session.target";
          Conflicts = "wallpaper-get.service";
        };
        Service = {
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStartPre = "${pkgs.bash}/bin/bash -c 'systemctl --user import-environment XDG_CURRENT_DESKTOP'";
          ExecStart = "${pkgs.wallpaper-switch}/bin/wallpaper-switch random";
          KillMode = "process";
        };
        Install = {
          WantedBy = [
            "default.target"
            "graphical-session.target"
          ];
        };
      };
    };
    timers = {
      wallpaper-get = {
        Unit = {
          Description = "Download wallpaper timer (every 30min, rotating sources)";
        };
        Timer = {
          OnUnitActiveSec = "30min";
          OnBootSec = "30min";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
      wallpaper-random = {
        Unit = {
          Description = "switch random wallpaper powered";
        };
        Timer = {
          OnUnitActiveSec = "60min";
          OnBootSec = "60min";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
    };
  };
}
