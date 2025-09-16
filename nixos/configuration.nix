# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
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
  # You can import other NixOS modules here
  imports = with outputs.nixosModules; [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.interception-tools
    podman
    ollama
    mihomo
    mail
    theme

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
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

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        # flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
        trusted-users = [ "${me.username}" ];
        # the system-level substituers & trusted-public-keys
        # given the users in this list the right to specify additional substituters via:
        #    1. `nixConfig.substituers` in `flake.nix`
        substituters = [
          # cache mirror located in China
          # status: https://mirror.sjtu.edu.cn/
          # "https://mirror.sjtu.edu.cn/nix-channels/store"
          # status: https://mirrors.ustc.edu.cn/status/
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          # the default public key of cache.nixos.org, it's built-in, no need to add it here
          # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
      # do garbage collection weekly to keep disk usage low
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
      # Opinionated: disable channels
      channel.enable = false;
    };

  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.packages = with pkgs; [
    terminus_font
  ];
  console = {
    earlySetup = true;
    font = "ter-132b";
    # keyMap = "us";
    # useXkbConfig = true; # use xkb.options in tty.
  };
  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver = {
  #   layout = "us";
  #  xkbVariant = "";
  # }

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    # increase audio buffer size to avoid audio glitches
    extraConfig.pipewire = {
      "99-custom" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 8192;
        };
      };
    };

  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      git
      parted
      fbida
      pciutils
      vulkan-tools
      home-manager
      cachix
      nixos-generators
      # to run nixos-anywhere store and kexec locally:
      # nix build .#nixosConfigurations.my-server.config.system.build.toplevel -o result-nixos
      # nix build .#nixosConfigurations.my-server.config.system.build.diskoScript -o result-disko
      # nixos-anywhere --store-paths result-disko result-nixos --kexec ./nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz --no-substitute-on-destination myserver.example.com
      nixos-anywhere
      tree
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    bash = {
      blesh.enable = true;
      vteIntegration = true;
    };
    nix-ld.enable = true;
  };

  systemd.sleep.extraConfig = ''
    [Sleep]
    HibernateMode=shutdown
  '';

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  security.pam.loginLimits = [
    {
      domain = "*";
      item = "nofile";
      type = "-";
      value = "32768";
    }
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
