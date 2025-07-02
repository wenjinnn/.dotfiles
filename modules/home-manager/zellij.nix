{ config, ... }:
{
  programs.zellij = {
    enable = true;
  };
  xdg.configFile = {
    zellij = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.DOTFILES}/xdg/config/zellij";
    };
  };
}
