{ pkgs, lib, ... }:
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
  qt = {
    enable = true;
    # style = {
    #   name = "adwaita-dark";
    # };
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
# { pkgs, me, ... }:
# {
#   home.pointerCursor = {
#     gtk.enable = true;
#     x11.enable = true;
#   };
#   dconf.enable = true;
#   dconf.settings = {
#     "org/gnome/desktop/interface" = {
#       color-scheme = "prefer-dark";
#     };
#   };
#
#   stylix = {
#     enable = true;
#     polarity = "dark";
#     base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
#     cursor = {
#       name = "Adwaita";
#       package = pkgs.adwaita-icon-theme;
#       size = 24;
#     };
#     targets = {
#       neovim.enable = false;
#       qt.enable = false;
#       gtk.enable = false;
#       firefox = {
#         colorTheme.enable = true;
#         firefoxGnomeTheme.enable = true;
#         profileNames = [ me.username ];
#       };
#     };
#     fonts = {
#       sizes = {
#         terminal = 11;
#         desktop = 11;
#       };
#     };
#   };
#
#   # qt.enable = true;
#   # gtk.enable = true;
# }
