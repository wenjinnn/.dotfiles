{pkgs, config, ...}: {
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
          WantedBy = ["default.target"];
        };
      };
      wallpaper-random = {
        Unit = {
          Description = "switch random wallpaper powered by hyprpaper";
          After = "bingwallpaper-get.service";
        };
        Service = {
          Type = "oneshot";
          Environment = "HOME=${config.home.homeDirectory}";
          ExecStart = "${pkgs.wallpaper-switch}/bin/wallpaper-switch random";
        };
        Install = {
          WantedBy = ["default.target"];
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
        Install = {WantedBy = ["timers.target"];};
      };
      wallpaper-random = {
        Unit = {
          Description = "switch random wallpaper powered by hyprpaper timer";
        };
        Timer = {
          OnUnitActiveSec = "60min";
          OnBootSec = "60min";
        };
        Install = {WantedBy = ["timers.target"];};
      };
  };
  };
}
