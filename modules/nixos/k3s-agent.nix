{ serverAddr ? "https://nixos:6443" }:
{
  config,
  lib,
  ...
}:
{
  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets.K3S_TOKEN.path;
    extraFlags = [ "--flannel-iface=tailscale0" ];
    inherit serverAddr;
  };

  systemd.services.k3s = lib.mkIf config.services.tailscale.enable {
    after = [ "tailscaled.service" ];
    bindsTo = [ "tailscaled.service" ];
  };
}
