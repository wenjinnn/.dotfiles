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
  ];
  programs.niri.enable = true;

  services.gnome.gnome-keyring.enable = lib.mkForce false;
  systemd.user.services.niri-flake-polkit.enable = false;
  services.displayManager.dms-greeter.compositor.name = "niri";
  services.clight.enable = true;
}
