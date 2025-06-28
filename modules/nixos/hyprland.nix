{
  config,
  outputs,
  pkgs,
  me,
  inputs,
  lib,
  ...
}:
{
  imports = with outputs.nixosModules; [
    de-basic
  ];
  # can't work with custom gnome module from ./gnome.nix
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
  };

  # security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
  security = {
    pam.services.hyprlock = { };
  };

}
