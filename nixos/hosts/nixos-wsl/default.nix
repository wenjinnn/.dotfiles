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

  services.ollama.acceleration = "cuda";

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
