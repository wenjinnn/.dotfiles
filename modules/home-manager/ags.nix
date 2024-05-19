{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];
  home.packages = with pkgs; [
    unstable.matugen
    dart-sass
    bun
  ];
  # ags
  programs.ags = {
    enable = true;
    configDir = ../../xdg/config/ags;
    extraPackages = with pkgs; [
      accountsservice
    ];
  };
}
