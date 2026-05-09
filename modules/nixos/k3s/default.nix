{
  role ? "server",
  serverAddr ? null,
  moreExtraFlags ? [ ],
}:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = lib.optionals (role == "server") (
    with pkgs;
    [
      k9s
      kubernetes
      kubernetes-helm
      kubectl
    ]
  );
  environment.variables = lib.optionalAttrs (role == "server") {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  services.k3s = {
    enable = true;
    inherit role;
    tokenFile = config.sops.secrets.K3S_TOKEN.path;
    extraFlags = [
      "--flannel-iface=tailscale0"
    ]
    ++ lib.optionals (role == "server") [
      "--embedded-registry=true"
      "--write-kubeconfig-mode=644"
      "--write-kubeconfig-group=k3sconfig"
    ]
    ++ moreExtraFlags;
    clusterInit = serverAddr == null && role == "server";
    manifests = lib.mkIf (role == "server") {
      traefik-config.source = ./traefik-config.yaml;
    };
  }
  // lib.optionalAttrs (serverAddr != null) { inherit serverAddr; };

  systemd.services.k3s = lib.mkIf config.services.tailscale.enable {
    after = [ "tailscaled.service" ];
    bindsTo = [ "tailscaled.service" ];
  };

  environment.etc = {
    "rancher/k3s/registries.yaml" = {
      text = ''
        mirrors:
          docker.io:
            endpoint:
              - "https://registry-1.docker.io"
          rancher:
            endpoint:
              - "https://rancher.mirror.aliyuncs.com"
      '';
    };
  };
}
