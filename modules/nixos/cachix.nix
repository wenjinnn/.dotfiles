{ config, ...}: {
  services.cachix-watch-store = {
    enable = true;
    cacheName = "wenjinnn";
    cachixTokenFile = config.sops.secrets.CACHIX_TOKEN.path;
  };
}
