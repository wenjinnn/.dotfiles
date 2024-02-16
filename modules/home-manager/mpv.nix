{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # home.file = {
  #   ".config/mpv" = {
  #     source = ../../xdg/config/mpv;
  #     recursive = true;
  #   };
  # };
  programs.mpv = {
    enable = true;
    scripts = with pkgs.unstable; [
      mpvScripts.mpris
      mpvScripts.uosc
      mpvScripts.mpv-cheatsheet
      # mpvScripts.visualizer
      mpvScripts.cutter
      mpvScripts.autoload
      mpvScripts.thumbfast
      mpvScripts.vr-reversal
      mpvScripts.webtorrent-mpv-hook
      mpvScripts.quality-menu
    ];
    config = {
      osd-bar = "no";
      border = "no";
    };

  };
}
