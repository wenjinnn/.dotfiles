{ pkgs, me, ... }:
{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
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
      hyprlock.enable = false;
      neovim.enable = false;
      zellij.enable = false;
      qt.enable = true;
      firefox.profileNames = [ me.username ];
    };
    fonts = {
      sizes = {
        popups = 13;
        desktop = 11;
      };
    };
  };

  qt = {
    enable = true;
  };

  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.morewaita-icon-theme;
      name = "MoreWaita";
    };
  };
}
