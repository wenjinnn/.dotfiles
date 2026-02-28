{
  inputs,
  outputs,
  pkgs,
  config,
  lib,
  mainMonitor,
  ...
}:
{

  imports = with outputs.homeManagerModules; [
    de-basic
    waybar-vertical
    rofi
    kdeconnect
    wallpaper
  ];
  xdg.configFile = {
    niri = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.DOTFILES}/xdg/config/niri";
    };
  };

  services = {
    swayidle =
      let
        niri = lib.getExe pkgs.niri;
        swaylock = "${lib.getExe pkgs.swaylock} -f -i ${config.home.homeDirectory}/.local/share/.wallpaper";
      in
      {
        events = {
          "before-sleep" = "${swaylock} && ${niri} msg action power-off-monitors";
          "after-resume" = "${niri} msg action power-on-monitors";
        };
        timeouts = [
          {
            timeout = 300;
            command = swaylock;
          }
          {
            timeout = 360;
            command = "${niri} msg action power-off-monitors";
          }
        ];
      };
  };
}
