{ pkgs, me, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
  };
  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
    targets = {
      neovim.enable = false;
      qt.enable = true;
      firefox = {
        firefoxGnomeTheme.enable = true;
        profileNames = [ me.username ];
      };
    };
    fonts = {
      sizes = {
        terminal = 11;
        desktop = 11;
      };
    };
  };

  qt.enable = true;
  gtk.enable = true;
}
