{
  config,
  pkgs,
  me,
  inputs,
  lib,
  ...
}:
{
  # can't work with custom gnome module from ./gnome.nix
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  xdg.portal = {
    enable = true;
  };

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "footclient";
  };

  environment.systemPackages = with pkgs; [
    loupe
    adwaita-icon-theme
    file-roller
    baobab
    nautilus
    nautilus-python
    gnome-calendar
    gnome-system-monitor
    gnome-weather
    gnome-calculator
    gnome-clocks
    gnome-software # for flatpak
    wl-gammactl
    wl-clipboard
    wayshot
    pavucontrol
    brightnessctl
  ];

  # security.pam.services.gtklock.text = lib.readFile "${pkgs.gtklock}/etc/pam.d/gtklock";
  security = {
    polkit.enable = true;
    pam.services.hyprlock = { };
  };
  services = {
    gvfs.enable = true;
    upower.enable = true;
    udisks2.enable = true;
  };
  # tell Electron/Chromium to run on Wayland
  environment.variables.NIXOS_OZONE_WL = "1";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
        user = me.username;
      };
    };
  };

}
