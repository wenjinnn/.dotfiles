{pkgs, me, ...}: {

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

  security = {
    polkit.enable = true;
  };
  services = {
    gvfs.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    geoclue2.enable = true;
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
