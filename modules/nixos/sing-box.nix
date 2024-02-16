{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.sing-box = {
    package = pkgs.unstable.sing-box;
    enable = true;
  };
}
