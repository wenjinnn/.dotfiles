{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    matugen
    dart-sass
    bun
    ags
  ];
  home.file.".config/ags" = {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.DOTFILES}/xdg/config/ags";
  };
}
