{pkgs, ...}: {
  # fcitx5
  i18n.inputMethod = {
    type = "fcitx5";
    fcitx5 = {
      plasma6Support = true;
      waylandFrontend = true;
    };
  };
}
