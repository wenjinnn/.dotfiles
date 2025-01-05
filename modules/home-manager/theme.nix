{pkgs, ...}: {
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
    image = pkgs.fetchurl {
      url = "https://www.bing.com/th?id=OHR.ArdezSwitzerland_ROW0603494655_UHD.jpg&rf=LaDigue_UHD.jpg&pid=hp";
      sha256 = "sha256-EMjJajEVkD4CB38cV6QbLc4N2o1n0KliktO9NX+CXjI=";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
    cursor = {
      name = "Adwaita";
      size = 24;
    };
    targets = {
      hyprlock.enable = false;
      neovim.enable = false;
    };
    fonts = {
      sizes = {
        popups = 13;
        desktop = 11;
      };
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font";
      };
    };
  };

  qt = {
    enable = true;
    style = {
      name = "adwaita-dark";
    };
    platformTheme.name = "adwaita";
  };

  gtk = {
    enable = true;

    iconTheme = {
      package = pkgs.morewaita-icon-theme;
      name = "MoreWaita";
    };
  };
}
