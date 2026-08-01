{
  inputs,
  outputs,
  pkgs,
  lib,
  mainMonitor,
  config,
  me,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs = {
    noctalia = {
      enable = true;
      systemd.enable = true;
      settings = builtins.fromTOML (builtins.readFile ../../xdg/config/noctalia/config.toml);
    };
  };

}
