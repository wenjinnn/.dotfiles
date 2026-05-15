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
      nfs-utils
    ]
  );

  environment.variables = lib.optionalAttrs (role == "server") {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  services.openiscsi = lib.mkIf (config.networking.hostName != "rpi5") {
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
        "--embedded-registry=true"
        "--write-kubeconfig-mode=644"
        "--write-kubeconfig-group=k3sconfig"
      ]
      ++ moreExtraFlags;
      clusterInit = initMachine;
      manifests = lib.mkIf initMachine {
        traefik-config.source = ./traefik-config.yaml;
      };
      autoDeployCharts = lib.mkIf initMachine {
        longhorn = {
          repo = "https://charts.longhorn.io";
          version = "v1.11.2";
          name = "longhorn";
          targetNamespace = "longhorn-system";
          createNamespace = true;
          hash = "sha256-pwJyyDaDkj7ZyvoH/h5POm59XXSHQRGzqK1CHmQQKnc=";
          values = {
            global = {
              nodeSelector = {
                longhorn-storage-node = "enabled";
              };
            };
            defaultSettings = {
              systemManagedComponentsNodeSelector = "longhorn-storage-node:enabled";
            };
          };
        };
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
