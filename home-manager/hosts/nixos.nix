{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  me,
  ...
}:
{
  imports = with outputs.homeManagerModules; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    de
    fcitx5
    mpv
    ghostty
    paseo
  ];

  sops.secrets.PASEO_PASSWORD = { };

  services.paseo = {
    enable = true;
    listenAddress = "0.0.0.0";
    hostnames = true;
    relay.enable = false;
    settings.features.webUi.enabled = true;
    connectedHosts = [
      {
        label = "nixos-wsl";
        endpoint = "tcp://nixos-wsl.ts.${me.domain}:6767";
        passwordFile = config.sops.secrets.PASEO_PASSWORD.path;
      }
      {
        label = "rpi5";
        endpoint = "tcp://rpi5.ts.${me.domain}:6767";
        passwordFile = config.sops.secrets.PASEO_PASSWORD.path;
      }
    ];
  };

  # nixpkgs.config.permittedInsecurePackages = [
  #   "openssl-1.1.1w"
  # ];

  gtk.gtk3.bookmarks =
    let
      homePath = "file://${config.home.homeDirectory}";
    in
    [
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
    wayscriber
    darktable
    scrcpy
    wireshark
    mitmproxy
    waydroid
    telegram-desktop
    discord
    dbx
    # temp disabled because of build error
    # redisinsight
    wechat
    shotcut
    qq
    wemeet
    wpsoffice-cn
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps-launcher
    # nur.repos.xddxdd.dingtalk
  ];
}
