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
    image = pkgs.fetchurl {
      url = "https://www.bing.com/th?id=OHR.NapoliPizza_ROW8840504063_UHD.jpg";
      sha256 = "sha256-1Andv0jmsakNgKv4n/q+McmL+eBYByxRiZ2A32rqo+I=";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-hard.yaml";
    cursor = {
      name = "Adwaita";
      package = pkgs.libadwaita;
      size = 24;
    };
    targets = {
      hyprlock.enable = false;
      neovim.enable = false;
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
