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
    image = pkgs.fetchurl {
      url = "https://www.bing.com/th?id=OHR.NapoliPizza_ROW8840504063_UHD.jpg";
      sha256 = "sha256-1Andv0jmsakNgKv4n/q+McmL+eBYByxRiZ2A32rqo+I=";
    };
    targets = {
      qt.enable = true;
    };
  };
}
