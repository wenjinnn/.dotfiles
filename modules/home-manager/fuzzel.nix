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
        terminal = "${pkgs.foot}/bin/foot -e";
        layer = "overlay";
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
