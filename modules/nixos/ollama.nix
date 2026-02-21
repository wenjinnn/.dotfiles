{
  pkgs,
  username,
  config,
  lib,
  ...
}
: {
  services = {
    ollama = {
      enable = true;
    };
  };
}
