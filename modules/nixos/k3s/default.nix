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

  services.k3s =
    let
      initMachine = serverAddr == null && role == "server";
    in
    {
      enable = true;
      inherit role;
      tokenFile = config.sops.secrets.K3S_TOKEN.path;
      extraFlags = [
        "--flannel-iface=tailscale0"
      ]
      ++ lib.optionals (role == "server") [
        "--write-kubeconfig-mode=644"
        "--write-kubeconfig-group=k3sconfig"
      ]
      ++ moreExtraFlags;
      clusterInit = initMachine;
      manifests = lib.mkIf initMachine {
        traefik-config.source = ./traefik-config.yaml;
        registry.source = ./registry-deploy.yaml;
      };
      autoDeployCharts = {
        longhorn = {
          repo = "https://charts.longhorn.io";
          version = "v1.11.2";
          name = "longhorn";
          targetNamespace = "longhorn-system";
          createNamespace = true;
          hash = "sha256-pwJyyDaDkj7ZyvoH/h5POm59XXSHQRGzqK1CHmQQKnc=";
          values = {
            defaultSettings = {
              createDefaultDiskLabeledNodes = true;
            };
            longhornDriver = {
              nodeSelector = {
                "longhorn.io/only" = "true";
              };
            };
            longhornManager = {
              nodeSelector = {
                "longhorn.io/only" = "true";
              };
            };
          };
        };
      };

    }
    // lib.optionalAttrs (serverAddr != null) { inherit serverAddr; };

  systemd.services.k3s = lib.mkMerge [
    (lib.mkIf config.services.tailscale.enable {
      after = [ "tailscaled.service" ];
      bindsTo = [ "tailscaled.service" ];
    })
  ];

  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/iscsiadm - - - - /run/current-system/sw/bin/iscsiadm"
  ];

  environment.etc = {
    "rancher/k3s/registries.yaml" = {
      text = ''
        mirrors:
          docker.io:
            endpoint:
              - "http://localhost:5000"
              - "https://registry-1.docker.io"
          rancher:
            endpoint:
              - "http://localhost:5000"
              - "https://rancher.mirror.aliyuncs.com"
      '';
    };
  };
}
