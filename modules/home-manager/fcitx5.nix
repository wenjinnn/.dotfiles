{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # xdg.configFile = {
  #   "fcitx5/profile" = {
  #     source = ../../xdg/config/fcitx5/profile;
  #     # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
  #     # so we need to force replace it in every rebuild to avoid file conflict.
  #     force = true;
  #   };
  #   "fcitx5/config".source = ../../xdg/config/fcitx5/config;
  #   "fcitx5/conf/classicui.conf".source = ../../xdg/config/fcitx5/conf/classicui.conf;
  # };
  # rime sync dir link to private repo
  xdg.dataFile = {
    "fcitx5/rime/sync" = {
      source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.sessionVariables.ARCHIVE}/rime/";
    };
  };
  # fcitx5
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
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
      settings = {
        inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "rime";
          "Groups/0/Items/2".Name = "mozc";
        };
        globalOptions = {
          Behavior = {
            ActiveByDefault = false;
          };
          Hotkey = {
            EnumerateWithTriggerKeys = true;
            EnumerateSkipFirst = false;
          };
          "Hotkey/TriggerKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/AltTriggerKeys" = {
            "0" = "Shift+L";
          };
          "Hotkey/EnumerateGroupForwardKeys" = {
            "0" = "Super+space";
          };
          "Hotkey/EnumerateGroupBackwardKeys" = {
            "0" = "Shift+Super+space";
          };
          Behavior = {
            PreeditEnabledByDefault = true;
            ShowInputMethodInformation = true;
            showInputMethodInformationWhenFocusIn = false;
            CompactInputMethodInformation = true;
            ShowFirstInputMethodInformation = true;
          };
        };
        addons = {
          classicui.globalSection.Theme = "stylix";
        };
      };

    };
  };
}
