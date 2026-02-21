# This module provides basic home manager desktop environment services and applications
{
  pkgs,
  lib,
  mainMonitor,
  config,
  me,
  ...
}:
{

  services = {
    # use pass as secret service, replaced gnome-keyring
    pass-secret-service.enable = true;
    # polkit gnome agent for privilege escalation in GUI apps
    polkit-gnome.enable = true;
    # auto adjust gamma to reduce eye strain base on timezone
    gammastep = {
      enable = true;
      dawnTime = "6:00-7:45";
      duskTime = "18:35-20:15";
      provider = "geoclue2";
      tray = true;
    };
    # clipboard manager
    cliphist.enable = true;
    # udisks2 GUI front end
    udiskie.enable = true;
    # notification daemon
    dunst = {
      enable = true;
      settings = {
        global = {
          monitor = mainMonitor;
          mouse_left_click = "context, close_current";
          # TODO maybe change rofi title
          dmenu = "${pkgs.rofi}/bin/rofi -dmenu -p action";
        };
        ignore_kde_connect = {
          appname = "KDE Connect";
          summary = "System UI";
          skip_display = true;
        };
      };
    };
    # idle daemon
    swayidle.enable = true;
  };
  # additional swayidle inhibit service to pause idle when audio is playing
  systemd.user.services.sway-audio-idle-inhibit = {
    Unit = {
      Description = "Inhibit swayidle when audio is playing";
      After = [ "swayidle.service" ];
      PartOf = [ "swayidle.service" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.sway-audio-idle-inhibit}";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  programs = {
    swaylock.enable = true;
    # vim like image viewer
    imv.enable = true;
    # vim like pdf viewer
    zathura = {
      enable = true;
      options = {
        recolor = true;
      };
    };
    # firefox with some native host messaging apps
    firefox = {
      enable = true;
      profiles = {
        "${me.username}" = {
          id = 0;
          extensions.force = true;
        };
      };
      nativeMessagingHosts = with pkgs; [
        # Tridactyl native connector
        tridactyl-native
        # Browserpass for pass integration
        browserpass
      ];
    };
  };

  home.packages = with pkgs; [
    wl-screenrec
    imagemagick
    slurp
    tesseract
    pavucontrol
    swappy
    brightnessctl
    playerctl
    pulseaudio
    gnupg
    blueberry
    cliphist
    wl-clipboard
    grim
    xrdb
    file-roller
    baobab
    nautilus
    nautilus-python
    gnome-calendar
    gnome-system-monitor
    gnome-weather
    gnome-calculator
    gnome-clocks
    gnome-software # for flatpak
    # vdhcoapp # for videodownloadhelper, the browser extension. for first time setup, run `vdhcoapp install`
  ];
  xdg = {
    # disable nm-applet autostart
    configFile."autostart/nm-applet.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Network Manager Applet
      Exec=nm-applet
      Hidden=true
    '';
    # customize nautilus right click menu
    dataFile."nautilus-python/extensions/image_tools_extension.py".source =
      ../../xdg/data/nautilus-python/extensions/image_tools_extension.py;
  };
}
