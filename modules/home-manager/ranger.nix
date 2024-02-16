{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {

  home.packages = with pkgs; [
    ranger
  ];
  home.file = {
    ".config/ranger" = {
      source = ../../xdg/config/ranger;
      recursive = true;
    };
  };
}
