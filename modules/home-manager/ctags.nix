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
    ".config/ctags".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.DOTFILES}/xdg/config/ctags";
  };
}
