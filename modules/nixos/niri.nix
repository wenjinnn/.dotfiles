{
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
    outputs.nixosModules.de-basic
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  systemd.user.services.niri-flake-polkit = lib.mkForce { };
}
