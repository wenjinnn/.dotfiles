# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = with outputs.nixosModules; [
    # If you want to use modules your own flake exports (from modules/nixos):
    interception-tools
    firewall
    virt
    systemd-boot
    waydroid
    bluetooth
    steam
    de

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

  programs.kdeconnect.enable = true;

  nixpkgs.config.rocmSupport = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  services.ollama = {
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1101"; # used to be necessary, but doesn't seem to anymore
      OLLAMA_KEEP_ALIVE = "30m";
    };
    rocmOverrideGfx = "11.0.1";
  };

  environment.systemPackages = with pkgs; [
    lact
    nvtopPackages.amd
    nvtopPackages.intel
    tpacpi-bat
  ];
  systemd.packages = with pkgs; [ lact ];
  hardware.amdgpu.overdrive.enable = true;
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
  powerManagement.powertop.enable = true;
  services = {
    printing.enable = true;
    flatpak.enable = true;
    thermald.enable = true;
  };
  services.hardware.bolt.enable = true;

  boot.extraModprobeConfig = ''
    options snd-hda-intel enable=1,0  # only enable the first audio card
    blacklist snd_hda_codec_hdmi  # disable HDMI audio output
  '';

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [
        "com.mitchellh.ghostty.desktop"
      ];
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  networking.hostName = "nixos";
}
