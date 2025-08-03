{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
  services.gnome.gnome-keyring.enable = lib.mkForce false;
  systemd.user.services.niri-flake-polkit = lib.mkForce { };
  security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
}
