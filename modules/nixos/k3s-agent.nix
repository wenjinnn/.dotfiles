
{ config, ... }:
{
  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets.K3S_TOKEN.path;
    serverAddr = "https://nixos:6443";
  };
}
