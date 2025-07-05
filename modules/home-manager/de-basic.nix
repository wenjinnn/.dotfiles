{ pkgs, ... }:
{

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
