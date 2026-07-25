# NixOS module for basic nixos desktop environment services and programs
{
  inputs,
  outputs,
  config,
  pkgs,
  lib,
  me,
  ...
}:
{

  imports = with outputs.nixosModules; [
    niri
  ];
  programs = {
    # for camera support in file managers
    gphoto2.enable = true;
    # nautilus right-click "open in terminal"
    nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };
  };

  security = {
    # polkit for privilege escalation in GUI apps
    polkit.enable = true;
  };
  services = {
    # gvfs for file management in GUI apps, e.g. Nautilus
    gvfs.enable = true;
    # upower for battery status
    upower.enable = true;
    # udisks2 for mounting drives
    udisks2.enable = true;
    # used for location services, e.g. in Maps, gammastep
    geoclue2.enable = true;
    # accounts-daemon for those programs who base on login user account info, e.g. gtklock
    accounts-daemon.enable = true;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --background matrix --cmd niri-session";
      };
    };
  };
  location.provider = "geoclue2";
  environment.systemPackages = with pkgs; [
    nautilus
    libheif
    libheif.out
    ddcutil
    i2c-tools
  ];
  environment.pathsToLink = [ "share/thumbnailers" ];

  # tell Electron/Chromium to run on Wayland
  environment.variables.NIXOS_OZONE_WL = "1";
  # simple display manager daemon with tui

}
