{ lib, pkgs, ... }:
{
  programs = {
    noctalia = {
      package = pkgs.noctalia;
      enable = true;
      systemd.enable = true;
      settings = lib.mkForce (
        builtins.fromTOML (builtins.readFile ../../xdg/config/noctalia/config.toml)
      );
    };
  };

}
