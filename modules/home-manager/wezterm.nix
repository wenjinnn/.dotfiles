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
    extraConfig = builtins.readFile ../../xdg/config/wezterm/wezterm.lua;
  };
}
