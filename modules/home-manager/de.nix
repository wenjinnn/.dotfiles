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
  imports = [
    inputs.noctalia.homeModules.default
    outputs.homeManagerModules.niri
    outputs.homeManagerModules.wallpaper
  ];

  services = {
    pass-secret-service.enable = true;
    easyeffects.enable = true;
    # udisks2 GUI front end
    udiskie.enable = true;
  };
  programs = {
    noctalia = {
      enable = true;
      systemd.enable = true;
      settings = ../../xdg/config/noctalia/config.toml;
    };
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
        pywalfox-native
        # Tridactyl native connector
        tridactyl-native
      ];
    };
  };

  home.packages = with pkgs; [
    wl-clipboard
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
  xdg = let
    eePresets = pkgs.fetchFromGitHub {
      owner = "JackHack96";
      repo = "EasyEffects-Presets";
      rev = "dd966e41ad9e44d4b11e19047f526ba718bbbe57";
      hash = "sha256-JpQVWuEokBRu01xkGA22dPeV5Jo8Xzvfrg5oQ8RtIrI=";
    };
    presetFiles = builtins.readDir "${eePresets}";
    jsonPresets = lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".json" name) presetFiles;
    irsFiles = builtins.readDir "${eePresets}/irs";
  in {
    configFile = {
      # disable nm-applet autostart
      "autostart/nm-applet.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Network Manager Applet
        Exec=nm-applet
        Hidden=true
      '';
    } // builtins.listToAttrs (
      # easyeffects presets from JackHack96/EasyEffects-Presets
      (map (name: {
        name = "easyeffects/output/${name}";
        value.source = "${eePresets}/${name}";
      }) (lib.attrNames jsonPresets))
      ++
      (map (name: {
        name = "easyeffects/irs/${name}";
        value.source = "${eePresets}/irs/${name}";
      }) (lib.attrNames irsFiles))
    );
    # customize nautilus right click menu
    dataFile."nautilus-python/extensions/image_tools_extension.py".source =
      ../../xdg/data/nautilus-python/extensions/image_tools_extension.py;
  };
}
