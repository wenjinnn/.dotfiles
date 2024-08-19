{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.file = {
    ".config/fcitx5".source = ../../xdg/config/fcitx5;
    ".local/share/fcitx5" = {
      source = ../../xdg/data/fcitx5;
      recursive = true;
    };
  };
  # fcitx5
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-mozc
      fcitx5-chinese-addons
    ];
  };
}
