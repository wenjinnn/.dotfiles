{ config, ...}: {
  services.cachix-agent = {
    enable = true;
    credentialsFile = config.sops.secrets.CACHIX_TOKEN.path;
  };
}
