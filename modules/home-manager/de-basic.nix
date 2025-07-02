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
  ];
}
