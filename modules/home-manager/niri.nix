{
  pkgs,
  config,
  lib,
  mainMonitor,
  ...
}:
{

  wayland.windowManager.niri = {
    enable = true;
    systemd.enable = true;
    extraConfig = builtins.readFile ../../xdg/config/niri/config.kdl;
  };
}
