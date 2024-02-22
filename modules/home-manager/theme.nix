{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    adw-gtk3
  ];

  home.sessionVariables = {
    GTK_THEME = "Adwaita-dark";
  };

  services = {
    xsettingsd = {
      enable = true;
      settings = {
        "Gdk/UnscaledDPI" = 98304;
        "Gdk/WindowScalingFactor" = 2;
      };
    };
  };

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
  qt = {
    enable = true;
    style = {
      package = with pkgs; [
        adwaita-qt
        adwaita-qt6
      ];
      name = "adwaita-dark";
    };
    platformTheme = "gnome";
  };
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.unstable.morewaita-icon-theme;
      name = "MoreWaita";
    };

  };
}
