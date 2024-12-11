{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "DejaVuSansM Nerd Font Mono:size=12";
        dpi-aware = "yes";
        terminal = "${pkgs.foot}/bin/footclient -e";
        layer = "overlay";
      };
      colors = {
        background = "171717ff";
        text = "eeeeeeff";
        selection = "373737ff";
        selection-text = "c4c4c4ff";
        border = "1f1f1fff";
        match = "5ba9e8ff";
        selection-match = "5ba9e8ff";
      };
      dmenu = {
        exit-immediately-if-empty = "yes";
      };
      border = {
        width = 1;
      };
    };
  };
}
