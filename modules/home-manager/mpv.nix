{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      memo
      uosc
      mpris
      cutter
      autoload
      thumbfast
      visualizer
      vr-reversal
      quality-menu
      mpv-cheatsheet
      webtorrent-mpv-hook
    ];
    config = {
      osd-bar = "no";
      border = "no";
    };
  };
}
