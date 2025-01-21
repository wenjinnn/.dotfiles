{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/virtualisation/amazon-image.nix")
  ];

  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";

      settings = {
        server_url = "http://hs.wenjin.me";
        dns = {
          base_domain = "ts.wenjin.me";
        };
      };
    };
  };
  environment.systemPackages = [config.services.headscale.package];

  system.stateVersion = "24.11";
}
