{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  me,
  ...
}:
{
  imports = with outputs.homeManagerModules; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    llm
    tmux
    sops
    startship
  ];
  home = {
    username = "${me.username}";
    homeDirectory = "/home/${me.username}";
  };
  programs.bash.enable = true;
}
