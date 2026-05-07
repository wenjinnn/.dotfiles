{ config, ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.K3S_TOKEN.path;
    clusterInit = true;
  };
}
