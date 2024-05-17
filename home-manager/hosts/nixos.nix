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
    unstable.rustdesk-flutter
    libreoffice
    evolution
    evolution-ews
    dbeaver
    gnome.gnome-tweaks
    gnome.gnome-themes-extra
    gnome.dconf-editor
    wireshark
    mitmproxy
    waydroid
    bottles
    telegram-desktop
    discord
    unstable.nixfmt-rfc-style
    nur.repos.wenjinnn.wechat-universal
    nur.repos.wenjinnn.hiddify-next
    nur.repos.xddxdd.dingtalk
    nur.repos.xddxdd.qq
    nur.repos.linyinfeng.wemeet
  ];
}
