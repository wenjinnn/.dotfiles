{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.sing-box = {
    enable = true;
  };
}
