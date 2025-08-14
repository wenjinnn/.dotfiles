{
  pkgs,
  lib,
  ...
}:
{

  services = {
    pass-secret-service.enable = true;
    polkit-gnome.enable = true;
    gammastep = {
      enable = true;
      dawnTime = "6:00-7:45";
      duskTime = "18:35-20:15";
      provider = "geoclue2";
      tray = true;
    };
    cliphist.enable = true;
    udiskie.enable = true;
    dunst = {
      enable = true;
      settings = {
        global = {
          mouse_left_click = "context, close_current";
          # TODO maybe change rofi title
          dmenu = "${pkgs.rofi-wayland}/bin/rofi -dmenu -p action";
        };
        ignore_kde_connect = {
          appname = "KDE Connect";
          summary = "System UI";
          skip_display = true;
        };
      };
    };
    swayidle =
      let
        gtklock = lib.getExe pkgs.gtklock;
      in
      {
        enable = true;
        extraArgs = [
          "-w"
        ];
        events = [
          {
            event = "lock";
            command = "${gtklock} -d";
          }
          {
            event = "before-sleep";
            command = "${gtklock} -d";
          }
        ];
        timeouts = [
          {
            timeout = 300;
            command = "${gtklock} -d";
          }
        ];
      };
  };
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
    imv.enable = true;
    zathura = {
      enable = true;
      options = {
        recolor = true;
      };
    };
    firefox.enable = true;
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
    xorg.xrdb
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
  ];
  xdg = {
    configFile."autostart/nm-applet.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Network Manager Applet
      Exec=nm-applet
      Hidden=true
    '';
    dataFile."nautilus-python/extensions/image_tools_extension.py".source =
      ../../xdg/data/nautilus-python/extensions/image_tools_extension.py;
  };
}
