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
    ".config/ctags".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.DOTFILES}/xdg/config/ctags";
  };
}
