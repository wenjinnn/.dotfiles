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
    de
    fcitx5
    mpv
    ghostty
    aria2
    theme
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

  services.remmina.enable = true;

  programs = {
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        input-overlay
      ];
    };
    obsidian = {
      enable = true;
      cli.enable = true;
    };
  };

  home.packages = with pkgs; [
    gimp3-with-plugins
    darktable
    scrcpy
    wireshark
    mitmproxy
    waydroid
    bottles
    telegram-desktop
    discord
    dbeaver-bin
    redisinsight
    wechat
    shotcut
    qq
    wemeet
    wpsoffice-cn
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps-launcher
    nur.repos.yakkhini.dingtalk
  ];
}
