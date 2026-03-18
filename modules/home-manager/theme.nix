{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Adwaita";
    size = 24;
  };
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "Sans 11";
      monospace-font-name = "Monospace 10";
      document-font-name = "Sans 11";
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Sans Bold 11";
    };
  };
  qt =
    let
      qtctSettings = {
        Appearance = {
          color_scheme_path = "${config.home.homeDirectory}/.config/qt5ct/colors/matugen.conf";
          style = "Fusion";
          icon_theme = "MoreWaita";
          standard_dialogs = "xdgdesktopportal";
        };
        Fonts = {
          fixed = "\"Sans,12\"";
          general = "\"Sans,12\"";
        };
      };
    in
    {
      enable = true;
      qt5ctSettings = qtctSettings;
      qt6ctSettings = qtctSettings;
      platformTheme.name = "gtk3";
    };
  home.packages = with pkgs; [
    adwaita-icon-theme
    hicolor-icon-theme
    adw-gtk3
  ];

  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.morewaita-icon-theme;
      name = "MoreWaita";
    };
  };
}
