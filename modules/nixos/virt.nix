{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # temporary disabled for compile error at this time
  # environment.systemPackages = with pkgs; [
  #   quickemu
  # ];
  # virtualisation
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
}
