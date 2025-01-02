{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.file = {
    ".config/fcitx5".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.DOTFILES}/xdg/config/fcitx5";
    ".local/share/fcitx5".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.sessionVariables.DOTFILES}/xdg/data/fcitx5";
  };
  # fcitx5
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      (fcitx5-rime.override {
        rimeDataPkgs = [
          nur.repos.xddxdd.rime-aurora-pinyin
          nur.repos.xddxdd.rime-custom-pinyin-dictionary
          nur.repos.xddxdd.rime-dict
          nur.repos.xddxdd.rime-ice
          nur.repos.xddxdd.rime-moegirl
          nur.repos.xddxdd.rime-zhwiki
          rime-data
        ];
      })
      fcitx5-mozc
      fcitx5-chinese-addons
      fcitx5-gtk
    ];
  };
}
