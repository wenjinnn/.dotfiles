# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  username,
  ...
}: {
  # You can import other home-manager modules here
  imports = with outputs.homeManagerModules; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    zsh
    starship
    neovim
    git
    ctags
    yazi
    mime
    git-sync
    btop
    lang
    direnv
    translate-shell
    ripgrep
    tmux
    sops
    mail
    mpd
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      # outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')/
    fastfetch
    ffmpeg
    distrobox
    bat
    fd
    ripgrep
    fzf
    socat
    lazygit
    jq
    lsd
    duf
    cowsay
    file
    which
    tree
    traceroute
    gnused
    gnutar
    gawk
    zstd
    gnupg
    du-dust
    inotify-tools
    libnotify
    lsof
    fhs
    appimage-run
    zip
    unzipNLS
    glib
    killall
    k9s
    minikube
    kubernetes
    kubectl
    autossh
    mermaid-cli
    mermaid-filter
    pandoc
    gh
    yq
    quicktype
    openpomodoro-cli
    cloc
    frp
    xdg-utils
    trashy
    w3m
    nix-index
    # for nvim dict
    wordnet
    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
  ];

  # xresources.properties = {
  #   "Xcursor.size" = 16;
  #   "Xft.dpi" = 172;
  # };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # ".config/qt5ct".source = ./xdg-config-home/qt5ct;
    # ".config/hypr" = {
    #   source = ./xdg-config-home/hypr;
    #   recursive = true;
    # };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/wenjin/etc/profile.d/hm-session-vars.sh
  #
  home.sessionPath = [
    # add oauth2 script
    "${config.home.homeDirectory}/.local/bin"
  ];
  home.sessionVariables = {
    DOTFILES = "${config.home.homeDirectory}/.dotfiles";
    ARCHIVE = "${config.home.homeDirectory}/.archive";
    SOPS_SECRETS = "${config.home.sessionVariables.DOTFILES}/secrets.yaml";
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
  };

  programs.bash.enable = true;

  programs = {
    imv.enable = true;
    zathura = {
      enable = true;
      options = {
        recolor = true;
      };
    };
  };

  # Enable home-manager
  programs.home-manager.enable = true;
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    maxCacheTtl = 60480000;
    defaultCacheTtl = 60480000;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
