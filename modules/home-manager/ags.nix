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
    inputs.matugen.packages.${pkgs.system}.default
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
