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

  services.ollama.acceleration = "rocm";

  boot.kernelParams = ["amdgpu.pcie_gen_cap=0x40000"];

  systemd.packages = with pkgs; [
    nvtopPackages.full
    lact
  ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];
  services = {
    printing.enable = true;
    flatpak.enable = true;
    tlp.settings = {
      INTEL_GPU_MIN_FREQ_ON_AC = 300;
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
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
