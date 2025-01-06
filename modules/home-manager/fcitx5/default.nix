{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile;
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };
    "fcitx5/config".source = ./config;
    "fcitx5/conf/classicui.conf".source = ./conf/classicui.conf;
  };
  # rime sync dir link to private repo
  xdg.dataFile = {
    "fcitx5/rime/sync" = {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.ARCHIVE}/rime/";
    };
  };
  home.sessionVariables = {
    # fix fcitx5 gtk module dark theme not work, can be remove after this PR merged: https://github.com/nix-community/home-manager/pull/5431
    GTK_IM_MODULE = lib.mkForce "";
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
      fcitx5-gtk
    ];
  };
}
