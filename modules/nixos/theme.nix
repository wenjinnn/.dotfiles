{pkgs, ...}: {
  stylix = {
    enable = true;
    polarity = "dark";
    cursor = {
      package = pkgs.libadwaita;
      name = "Adwaita";
      size = 24;
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
    targets = {
      qt.enable = true;
      console.enable = false;
    };
  };
}
