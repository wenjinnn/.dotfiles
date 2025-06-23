{ pkgs, config, ... }:
{
  # custom wallpaper services
  systemd.user = {
    services = {
      bingwallpaper-get = {
        Unit = {
          Description = "Download bing wallpaper to target path";
        };
        Service = {
          Type = "oneshot";
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStart = "${pkgs.bingwallpaper-get}/bin/bingwallpaper-get";
          ExecStartPost = "${pkgs.wallpaper-switch}/bin/wallpaper-switch";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
      wallpaper-random = {
        Unit = {
          Description = "switch random wallpaper powered by swaybg";
          After = "graphical-session.target";
          PartOf = "graphical-session.target";
        };
        Service = {
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStart = "${pkgs.wallpaper-switch}/bin/wallpaper-switch random";
          ExecReload = "${pkgs.wallpaper-switch}/bin/wallpaper-switch random";
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
      bingwallpaper-get = {
        Unit = {
          Description = "Download bing wallpaper timer";
        };
        Timer = {
          OnCalendar = "hourly";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };
      wallpaper-random = {
        Unit = {
          Description = "switch random wallpaper powered by swaybg timer";
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
