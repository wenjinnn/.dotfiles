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
}: let
  dotfiles_path = "${config.home.homeDirectory}/.dotfiles";
  archive_path = "${config.home.homeDirectory}/.archive";
in {
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
    syncthing
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
    username = "${me.username}";
    homeDirectory = "/home/${me.username}";
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
    yq
    quicktype
    openpomodoro-cli
    cloc
    frp
    xdg-utils
    trashy
    w3m
    networkmanagerapplet
    browserpass
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
    DOTFILES = dotfiles_path;
    ARCHIVE = archive_path;
    SOPS_SECRETS = "${dotfiles_path}/secrets.yaml";
  };

  xdg = {
    enable = true;
    userDirs.enable = true;
  };


  programs = {
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-copilot
        gh-models
      ];
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    mangohud = {
      enable = true;
      settings = {
        cpu_temp = true;
        gpu_temp = true;
        ram = true;
        vram = true;
        font_scale = lib.mkForce 2.0;
        background_alpha = lib.mkForce 0.5;
      };
    };
    # Enable home-manager
    home-manager.enable = true;
    gpg.enable = true;
    bash.enable = true;
    imv.enable = true;
    browserpass.enable = true;
    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [
        exts.pass-otp
        exts.pass-tomb
        exts.pass-file
        exts.pass-audit
        exts.pass-update
        exts.pass-import
        exts.pass-checkup
        exts.pass-genphrase
      ]);
      settings = {
        PASSWORD_STORE_DIR = "${archive_path}/password-store";
      };
    };
    zathura = {
      enable = true;
      options = {
        recolor = true;
      };
    };
  };

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
