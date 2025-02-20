{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    universal-ctags
  ];
  xdg.configFile = {
    "ctags".source = ../../xdg/config/ctags;
  };
}
