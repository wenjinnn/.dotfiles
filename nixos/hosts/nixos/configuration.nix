# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = with outputs.nixosModules; [
    # If you want to use modules your own flake exports (from modules/nixos):
    interception-tools
    firewall
    virt
    systemd-boot
    waydroid
    fonts
    hyprland
    bluetooth
    steam
    theme
    fcitx5

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  programs.kdeconnect = {
    package = pkgs.kdePackages.kdeconnect-kde;
    enable = true;
  };

  nixpkgs.config.rocmSupport = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.ollama = {
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1101"; # used to be necessary, but doesn't seem to anymore
      OLLAMA_KEEP_ALIVE = "30m";
    };
    rocmOverrideGfx = "11.0.1";
  };

  environment.systemPackages = with pkgs; [lact];
  systemd.packages = with pkgs; [lact];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
  services = {
    printing.enable = true;
    flatpak.enable = true;
    tlp = {
      enable = true;
      settings = {
        INTEL_GPU_MIN_FREQ_ON_AC = 500;
        INTEL_GPU_MIN_FREQ_ON_BAT = 500;
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
      };
    };
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "org.codeberg.dnkl.footclient.desktop"
      ];
    };
  };

  networking.hostName = "nixos";
}
