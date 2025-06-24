{ pkgs, config, ... }:
{
  # custom wallpaper services
  systemd.user = {
    services = {
      bingwallpaper-get = {
        Unit = {
          Description = "Download bing wallpaper to target path";
          Conflicts = "wallpaper-random.service";
        };
        Service = {
          Type = "oneshot";
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStart = "${pkgs.bingwallpaper-get}/bin/bingwallpaper-get";
          KillMode = "process";
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
          Conflicts = "bingwallpaper-get.service";
        };
        Service = {
          Environment = "HOME=${config.home.homeDirectory}";
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
      bingwallpaper-get = {
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
