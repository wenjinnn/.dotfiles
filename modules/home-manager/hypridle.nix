{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.hypridle.homeManagerModules.default
  ];
  services.hypridle = let 
    hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
    hyprctl = "${pkgs.unstable.hyprland}/bin/hyprctl";
    loginctl = "${pkgs.systemd}/bin/loginctl";
  in {
    enable = true;
    lockCmd = "pidof hyprlock || ${hyprlock} && sleep 1";
    beforeSleepCmd = "${loginctl} lock-session && ${hyprctl} dispatch dpms off";
    afterSleepCmd = "${hyprctl} dispatch dpms on";
    listeners = [
      {
        timeout = 300;
        onTimeout = "${loginctl} lock-session";
      }
      {
        timeout = 360;
        onTimeout = "${hyprctl} dispatch dpms off";
        onResume = "${hyprctl} dispatch dpms on";
      }
    ];
  };
}
