{ serverAddr ? null }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    k9s
    kubernetes
    kubernetes-helm
    kubectl
  ];
  environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.K3S_TOKEN.path;
    disable = [ "traefik" ];
    extraFlags = [
      "--flannel-iface=tailscale0"
      "--write-kubeconfig-mode=644"
      "--write-kubeconfig-group=k3sconfig"
    ];
    clusterInit = serverAddr == null;
  } // lib.optionalAttrs (serverAddr != null) { inherit serverAddr; };

  systemd.services.k3s = lib.mkIf config.services.tailscale.enable {
    after = [ "tailscaled.service" ];
    bindsTo = [ "tailscaled.service" ];
  };
}
