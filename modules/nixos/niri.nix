{
  lib,
  pkgs,
  outputs,
  ...
}:
{
  imports = with outputs.nixosModules; [
    base
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
  };
  security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
}
