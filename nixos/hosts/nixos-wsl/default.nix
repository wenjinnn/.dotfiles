# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  me,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    (outputs.nixosModules.k3s {
      serverAddr = "https://nixos-wsl:6443";
    })
    # If you want to use modules your own flake exports (from modules/nixos):
    inputs.nixos-wsl.nixosModules.default
    ../../configuration.nix

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix
  ];

  services.openssh = {
    ports = [
      2222
    ];
  };
  boot.kernelModules = [
    "modprobe"
    "br_netfilter"
  ];

  services.ollama.package = pkgs.ollama-rocm;

  networking = {
    firewall.enable = false;
    hostName = "nixos-wsl";
  };

  wsl = {
    enable = true;
    defaultUser = "${me.username}";
    startMenuLaunchers = true;
    useWindowsDriver = true;
  };
}
