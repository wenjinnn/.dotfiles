{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.wallpaper-switch
  ];
  # custom wallpaper services
  systemd.user = {
    services = {
      bing-wallpaper-get = {
        Unit = {
          Description = "Download bing wallpaper to target path";
          After = "graphical-session.target";
          Conflicts = "wallpaper-random.service";
        };
        Service = {
          Type = "oneshot";
          Environment = [
            "HOME=${config.home.homeDirectory}"
          ];
          ExecStartPre = "${pkgs.bash}/bin/bash -c 'systemctl --user import-environment XDG_CURRENT_DESKTOP'";
          ExecStart = "${pkgs.wallpaper-get}/bin/wallpaper-get";
          KillMode = "process";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
      nasa-wallpaper-get = {
        Unit = {
          Description = "Download NASA APOD wallpaper to target path";
          After = "graphical-session.target";
          Conflicts = "wallpaper-random.service";
        };
        Service = {
          Type = "oneshot";
          Environment = [
            "HOME=${config.home.homeDirectory}"
            "WALLPAPER_SOURCE=nasa"
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
          Conflicts = "wallpaper-get.service nasa-wallpaper-get.service";
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
          Description = "Download bing wallpaper timer";
        };
        Timer = {
          OnUnitActiveSec = "30min";
          OnBootSec = "30min";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
      nasa-wallpaper-get = {
        Unit = {
          Description = "Download NASA APOD wallpaper timer";
        };
        Timer = {
          OnUnitActiveSec = "60min";
          OnBootSec = "1h 30min";
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
