{ pkgs, ... }:
{

  services = {
    pass-secret-service.enable = true;
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
}
