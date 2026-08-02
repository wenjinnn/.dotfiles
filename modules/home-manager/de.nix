# This module provides basic home manager desktop environment services and applications
{
  inputs,
  outputs,
  pkgs,
  lib,
  mainMonitor,
  config,
  me,
  ...
}:
{
  imports = with outputs.homeManagerModules; [
    noctalia
    niri
    wallpaper
    kdeconnect
  ];

  services = {
    pass-secret-service.enable = true;
    easyeffects.enable = true;
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
    spotify
    nautilus-python
    gnome-calculator
    gnome-clocks
    gnome-software # for flatpak
    # vdhcoapp # for videodownloadhelper, the browser extension. for first time setup, run `vdhcoapp install`
  ];
  xdg =
    let
      eePresets = pkgs.fetchFromGitHub {
        owner = "JackHack96";
        repo = "EasyEffects-Presets";
        rev = "dd966e41ad9e44d4b11e19047f526ba718bbbe57";
        hash = "sha256-JpQVWuEokBRu01xkGA22dPeV5Jo8Xzvfrg5oQ8RtIrI=";
      };
      presetFiles = builtins.readDir "${eePresets}";
      jsonPresets = lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".json" name
      ) presetFiles;
      irsFiles = builtins.readDir "${eePresets}/irs";
    in
    {
      configFile = builtins.listToAttrs (
        # easyeffects presets from JackHack96/EasyEffects-Presets
        (map (name: {
          name = "easyeffects/output/${name}";
          value.source = "${eePresets}/${name}";
        }) (lib.attrNames jsonPresets))
        ++ (map (name: {
          name = "easyeffects/irs/${name}";
          value.source = "${eePresets}/irs/${name}";
        }) (lib.attrNames irsFiles))
      );
      # customize nautilus right click menu
      dataFile."nautilus-python/extensions/image_tools_extension.py".source =
        ../../xdg/data/nautilus-python/extensions/image_tools_extension.py;
    };
}
