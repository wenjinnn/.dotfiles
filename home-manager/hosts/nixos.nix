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
    de-basic
    # hyprland
    niri
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
    # temporary fix for libsoup
    "libsoup-2.74.3"
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

  services.remmina.enable = true;

  home.packages = with pkgs; [
    gimp3-with-plugins
    darktable
    obs-studio
    scrcpy
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
    shotcut
    qq
    wemeet
    obsidian
    obsidian-export
    wpsoffice-cn
    nur.repos.xddxdd.dingtalk
  ];
}
