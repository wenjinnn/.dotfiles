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
      openiscsi
      nfs-utils
    ]
  );

  environment.variables = lib.optionalAttrs (role == "server") {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
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
      longhorn = {
        source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml";
          hash = "sha256-taRC4AaZRYipY9DGKCsjRDxDefWc5BtSMLzAEr1ACyk=";
        };
      };
    };
  }
  // lib.optionalAttrs (serverAddr != null) { inherit serverAddr; };

  systemd.services.k3s = lib.mkIf config.services.tailscale.enable {
    after = [ "tailscaled.service" ];
    bindsTo = [ "tailscaled.service" ];
  };
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm"
  ];

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
  # 确保内核模块可用
  boot.kernelModules = [ "iscsi_tcp" ];
}
