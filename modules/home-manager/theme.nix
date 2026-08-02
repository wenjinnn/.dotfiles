{
  pkgs,
  lib,
  config,
  me,
  ...
}:
{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    # package = pkgs.bibata-cursors;
    # name = "Bibata-Modern-Classic";
    size = 24;
  };
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    cursor = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    targets = {
      # neovim.enable = false;
      # qt.enable = false;
      # gtk.enable = false;
      firefox = {
        colorTheme.enable = true;
        # firefoxGnomeTheme.enable = true;
        profileNames = [ me.username ];
      };
    };
    fonts = {
      monospace = {
        name = "CaskaydiaCove Nerd Font";
        package = pkgs.nerd-fonts.caskaydia-cove;
      };
      sansSerif = {
        name = "Ubuntu Nerd Font";
        package = pkgs.nerd-fonts.ubuntu-sans;
      };
      serif = {
        name = "Source Han Serif";
        package = pkgs.source-han-serif;
      };
      sizes = {
        terminal = 11;
        desktop = 11;
      };
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct";
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
