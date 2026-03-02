{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    outputs.nixosModules.de-basic
  ];
  programs.niri.enable = true;
  services.gnome.gnome-keyring.enable = lib.mkForce false;
}
