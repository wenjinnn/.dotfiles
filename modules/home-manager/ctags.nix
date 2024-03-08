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
  home.file = {
    ".config/ctags".source = ../../xdg/config/ctags;
  };
}
