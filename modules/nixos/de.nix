# NixOS module for basic nixos desktop environment services and programs
{
  inputs,
  outputs,
  config,
  pkgs,
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
    clight = {
      enable = true;
      settings = {
        inhibit_pm = false;
        inhibit_bl = true;
        ac_regression_points = [
          0.0
          0.20
          0.34
          0.50
          0.66
          0.79
          0.86
          0.93
          0.95
          0.97
          1.0
        ];
      };
    };
    displayManager.dms-greeter = {
      enable = true;
      configHome = config.users.users.${me.username}.home;
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

  programs.dms-shell = {
    enable = true;
    package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  # tell Electron/Chromium to run on Wayland
  environment.variables.NIXOS_OZONE_WL = "1";
  # simple display manager daemon with tui


}
