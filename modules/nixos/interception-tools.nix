{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.interception-tools = {
    enable = true;
    plugins = [
      pkgs.interception-tools-plugins.dual-function-keys
    ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.dual-function-keys}/bin/dual-function-keys -c /etc/interception/capslock2ctrlesc.yaml | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          LINK: /dev/input/by-path/platform-i8042-serio-0-event-kbd
    '';
  };
  environment.etc."interception/capslock2ctrlesc.yaml".text = ''
    TIMING:
        TAP_MILLISEC: 200
        DOUBLE_TAP_MILLISEC: 150

    MAPPINGS:
        - KEY: KEY_CAPSLOCK
          TAP: KEY_ESC
          HOLD: KEY_LEFTCTRL
  '';
}
