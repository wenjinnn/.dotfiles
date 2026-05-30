# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  me,
  ...
}:
let
  dotfiles_path = "${config.home.homeDirectory}/.dotfiles";
  archive_path = "${config.home.homeDirectory}/Sync/archive";
  note_path = "${config.home.homeDirectory}/.note";
in
{
  # You can import other home-manager modules here
  imports = with outputs.homeManagerModules; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    starship
    sops
    tmux
    llm
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "${me.username}";
    homeDirectory = "/home/${me.username}";
  };

  home.sessionVariables = {
    # where this repo should be placed
    DOTFILES = dotfiles_path;
    # private stuff
    ARCHIVE = archive_path;
    NOTE = note_path;
    # sops secrets file location
    SOPS_SECRETS = "${dotfiles_path}/secrets.yaml";
    # setup terminal sounds player
    PLAYER = "ffplay -nodisp -autoexit -loglevel quiet";
  };
  # Nix garbage collection settings
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  programs = {
    # Enable home-manager
    home-manager.enable = true;
    # A well configured bash is batter then other amazing shells?
    # After all you can't avoid bash completely
    bash = {
      enable = true;
      enableVteIntegration = true;
      historyControl = [
        "erasedups"
        "ignoreboth"
      ];
    };
    atuin = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "10m";
        sync_address = "http://atuin.ts.wenjin.me";
        key_path = config.sops.secrets.ATUIN_KEY.path;
      };
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      config = {
        load_dotenv = true;
      };
    };
    bat.enable = true;
    fd.enable = true;
    ripgrep = {
      enable = true;
      arguments = [
        "--glob=!.git/*"
        "--glob=!**/target"
        "--glob=!**/node_modules"
        "--glob=!**/tags"
        "--glob=!**/rime/*.dict.yaml"
        "--glob=!**/.direnv"
        "--smart-case"
        "--hidden"
        "--no-ignore-vcs"
      ];
    };
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
  };
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
