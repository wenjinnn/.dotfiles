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
    sassc
  ];
  # ags
  programs.ags = {
    enable = true;
    configDir = ../../xdg/config/ags;
    extraPackages = with pkgs; [
      libgtop
      libsoup_3
    ];
  };

}
