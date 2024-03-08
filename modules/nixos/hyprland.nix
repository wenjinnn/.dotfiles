{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  security = {
    polkit.enable = true;
  };
  xdg.portal = {
    enable = true;
  };
  # security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
  security.pam.services.swaylock = {};
  services = {
    gvfs.enable = true;
    devmon.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    accounts-daemon.enable = true;
  };
}
