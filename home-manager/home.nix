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
  archive_path = "${config.home.homeDirectory}/.archive";
  note_path = "${config.home.homeDirectory}/.note";
in
{
  # You can import other home-manager modules here
  imports = with outputs.homeManagerModules; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    starship
    neovim
    git
    ctags
    yazi
    mime
    git-sync
    lang
    translate-shell
    sops
    mail
    mpd
    rclone
    tmux
    llm
    theme
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.niri.overlays.niri
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
    ffmpeg
    socat
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
    dust
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
    sshfs
    mermaid-cli
    mermaid-filter
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
    devenv
    nix-init
    typst
    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor
    nixpkgs-review
    treefmt
    posting
    rpi-imager
    nmap
    john
    dig
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
    # add customize script path
    "${config.home.homeDirectory}/.local/bin"
  ];
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
    # sudo askpass program
    SUDO_ASKPASS = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
  };
  # XDG base directory settings
  xdg = {
    enable = true;
    userDirs.enable = true;
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
    # github cli
    gh = {
      enable = true;
      extensions = with pkgs; [
        github-copilot-cli
      ];
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
      config = {
        load_dotenv = true;
      };
    };
    nix-index = {
      enable = true;
      enableBashIntegration = true;
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
    fastfetch.enable = true;
    distrobox.enable = true;
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
    jq.enable = true;
    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
    # batter z
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd z" ];
    };
    # batter ls
    lsd = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        display = "all";
      };
    };
    gpg.enable = true;
    browserpass.enable = true;
    pandoc.enable = true;
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
  };

  services = {
    syncthing.enable = true;
    gpg-agent = {
      enable = true;
      maxCacheTtl = 60480000;
      defaultCacheTtl = 60480000;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
