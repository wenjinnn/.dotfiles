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
    sing-box

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];

  programs.kdeconnect = {
    package = pkgs.kdePackages.kdeconnect-kde;
    enable = true;
  };

  services = {
    printing.enable = true;
    flatpak.enable = true;
    tlp.settings = {
      INTEL_GPU_MIN_FREQ_ON_AC = 300;
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
    };
  };

  networking.hostName = "nixos";
}
