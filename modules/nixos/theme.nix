{pkgs, ...}: {
  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";
    image = pkgs.fetchurl {
      url = "https://www.bing.com/th?id=OHR.ArdezSwitzerland_ROW0603494655_UHD.jpg&rf=LaDigue_UHD.jpg&pid=hp";
      sha256 = "sha256-EMjJajEVkD4CB38cV6QbLc4N2o1n0KliktO9NX+CXjI=";
    };
  };
}
