{ serverAddr ? null }:
{
  config,
  lib,
  ...
}:
{
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.K3S_TOKEN.path;
    clusterInit = serverAddr == null;
  } // lib.optionalAttrs (serverAddr != null) { inherit serverAddr; };

  systemd.services.k3s = lib.mkIf config.services.tailscale.enable {
    after = [ "tailscaled.service" ];
    bindsTo = [ "tailscaled.service" ];
  };
}
