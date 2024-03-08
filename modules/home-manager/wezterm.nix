{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  programs.wezterm = {
    enable = true;
    package = pkgs.unstable.wezterm;
    extraConfig = builtins.readFile ../../xdg/config/wezterm/wezterm.lua;
  };
}
