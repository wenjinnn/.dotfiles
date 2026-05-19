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
    starship
  ];
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "${me.username}";
    homeDirectory = "/home/${me.username}";
  };
  home.sessionPath = [
    # add customize script path
    "${config.home.homeDirectory}/.local/bin"
  ];
  home.sessionVariables = {
    # sops secrets file location
    SOPS_SECRETS = "${config.home.homeDirectory}/.dotfiles/secrets.yaml";
  };

  home.stateVersion = "26.05";
  programs.bash.enable = true;
}
