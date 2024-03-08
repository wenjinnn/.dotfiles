{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    quickemu
  ];
  # virtualisation
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
}
