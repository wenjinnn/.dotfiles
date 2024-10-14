{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = with outputs.homeManagerModules; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    hyprland
    fcitx5
    theme
    mpv
    foot
    vscode
    aria2
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
    "electron-19.1.9"
  ];

  home.packages = with pkgs; [
    microsoft-edge
    gimp
    obs-studio
    scrcpy
    rustdesk-flutter
    libreoffice
    evolution
    evolution-ews
    gnome-tweaks
    gnome-themes-extra
    dconf-editor
    wireshark
    mitmproxy
    waydroid
    bottles
    telegram-desktop
    discord
    showmethekey
    dbeaver-bin
    redisinsight
    wechat-uos
    qq
    nur.repos.xddxdd.dingtalk
    nur.repos.linyinfeng.wemeet
  ];
}
