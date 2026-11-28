# This module provides basic home manager desktop environment services and applications
{
  outputs,
  pkgs,
  lib,
  me,
  ...
}:
{
  imports = with outputs.homeManagerModules; [
    noctalia
    umbriel
    wallpaper
    kdeconnect
    easyeffects
  ];

  services = {
    pass-secret-service.enable = true;
    # udisks2 GUI front end
    udiskie.enable = true;
  };
  # EasyEffects 8 (Qt) checks the system tray only once at startup (QSystemTrayIcon::isSystemTrayAvailable),
  # which races with noctalia's tray watcher (StatusNotifierWatcher) at startup, causing the tray icon to appear inconsistently.
  # Disabling the showTrayIcon preference deterministically disables the icon. xdg.configFile cannot be used:
  # KConfig rewrites this file at runtime, which conflicts with the store's read-only symlink, so write it once via activation.
  home.activation.setEasyEffectsNoTray = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 \
      --file easyeffects/db/easyeffectsrc \
      --group Window --key showTrayIcon false
  '';
  programs = {
    # vim like image viewer
    imv.enable = true;
    # vim like pdf viewer
    zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
        recolor = true;
      };
    };
    # firefox with some native host messaging apps
    firefox = {
      enable = true;
      profiles = {
        "${me.username}" = {
          id = 0;
          extensions.force = true;
        };
      };
      nativeMessagingHosts = with pkgs; [
        # pywalfox-native
        # Tridactyl native connector
        tridactyl-native
      ];
    };
  };

  home.packages = with pkgs; [
    wl-clipboard
    wl-kbptr
    yt-dlp
    spotdl
    kdePackages.qt6ct
    libsForQt5.qt5ct
    imagemagick
    slurp
    tesseract
    pavucontrol
    satty
    brightnessctl
    playerctl
    pulseaudio
    gnupg
    xrdb
    file-roller
    baobab
    nautilus
    nautilus-python
    gnome-calculator
    gnome-clocks
    gnome-software # for flatpak
    # vdhcoapp # for videodownloadhelper, the browser extension. for first time setup, run `vdhcoapp install`
  ];
  xdg.dataFile."nautilus-python/extensions/image_tools_extension.py".source =
    ../../xdg/data/nautilus-python/extensions/image_tools_extension.py;
}
