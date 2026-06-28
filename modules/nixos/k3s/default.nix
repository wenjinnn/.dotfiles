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
    {
      # Prevent rapid restart loops: max 5 attempts per 5 min, then systemd stops trying.
      # After the interval resets, it'll try again — this gives etcd time to "cool down"
      # and avoids burning 100% CPU on hopeless quorum attempts.
      unitConfig.StartLimitBurst = 5;
      unitConfig.StartLimitIntervalSec = 300;

      # Cap CPU so a runaway etcd election loop doesn't starve the desktop.
      serviceConfig.CPUQuota = "200%";

      # Back off restarts: first retry 5s, then 15s, 30s, 60s, 60s.
      # Oneshot preStart (below) gates the real start so we only burn restart
      # budget on genuine failures, not on "tailscale isn't up yet".
      serviceConfig.RestartSec = "5s";
      serviceConfig.RestartSteps = 4;
      serviceConfig.RestartMaxDelaySec = "60s";

      # Wait for Tailscale to be online and (for joining servers) for the init
      # server to be reachable before k3s attempts embedded etcd.  This avoids
      # the classic "etcd can't get quorum, burns CPU for 10 min" scenario.
      preStart = lib.mkIf (serverAddr != null) (
        let
          serverHost = builtins.head (
            lib.splitString ":" (lib.removePrefix "https://" (lib.removePrefix "http://" serverAddr))
          );
        in
        ''
          echo "k3s-pre-start: waiting for tailscale connectivity…"
          for i in $(seq 1 90); do
            if tailscale status --self 2>/dev/null | grep -q "active\|idle"; then
              echo "k3s-pre-start: tailscale is online"
              break
            fi
            sleep 2
          done

          echo "k3s-pre-start: waiting for server ${serverHost}…"
          for i in $(seq 1 30); do
            if ${pkgs.iputils}/bin/ping -c 1 -W 3 "${serverHost}" >/dev/null 2>&1; then
              echo "k3s-pre-start: server ${serverHost} is reachable"
              break
            fi
            sleep 2
          done
        ''
      );
    }
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
}
