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
    browser
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

  gtk.gtk3.bookmarks = let
    homePath = "file://${config.home.homeDirectory}";
  in [
    "${homePath}/Documents"
    "${homePath}/Downloads"
    "${homePath}/Music"
    "${homePath}/Pictures"
    "${homePath}/Public"
    "${homePath}/Repo"
    "${homePath}/Templates"
    "${homePath}/Videos"
  ];

  home.packages = with pkgs; [
    gimp
    obs-studio
    scrcpy
    rustdesk-flutter
    libreoffice
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
    wemeet
    nur.repos.xddxdd.dingtalk
  ];
}
