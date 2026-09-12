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
          version = "v1.12.1";
          name = "longhorn";
          targetNamespace = "longhorn-system";
          createNamespace = true;
          hash = "sha256-yM9LNanYcs1ffkT9JtjmrHwquu5C9OLyoLDrvG46YRY=";
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
      serviceConfig.ExecStartPre = [
        (pkgs.writeShellScript "k3s-wait-for-tailscale" ''
          for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
            if ${pkgs.iproute2}/bin/ip -4 addr show dev tailscale0 scope global | ${pkgs.gnugrep}/bin/grep -q 'inet '; then
              exit 0
            fi
            ${pkgs.coreutils}/bin/sleep 1
          done
          echo "tailscale0 has no global IPv4 address after 60 seconds" >&2
          exit 1
        '')
      ];
    }
  ];

  # The bootstrap server may be offline while the other two servers stay up.
  # Keep its workloads movable before planned shutdown and restore scheduling on boot.
  systemd.services.k3s-node-drain = lib.mkIf (role == "server" && serverAddr == null) {
    description = "Drain nixos workloads before shutdown";
    wantedBy = [ "multi-user.target" ];
    after = [
      "k3s.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    before = [ "shutdown.target" ];
    environment.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.kubectl}/bin/kubectl cordon ${config.networking.hostName} || true; ${pkgs.kubectl}/bin/kubectl drain ${config.networking.hostName} --ignore-daemonsets --delete-emptydir-data --timeout=60s || true'";
      TimeoutStopSec = "75s";
    };
    restartIfChanged = false;
    stopIfChanged = false;
  };

  systemd.services.k3s-node-uncordon = lib.mkIf (role == "server" && serverAddr == null) {
    description = "Uncordon nixos after k3s is ready";
    wantedBy = [ "multi-user.target" ];
    after = [
      "k3s.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    environment.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    script = ''
      for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
        if ${pkgs.kubectl}/bin/kubectl uncordon ${config.networking.hostName}; then
          exit 0
        fi
        ${pkgs.coreutils}/bin/sleep 5
      done
      exit 1
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "6min";
    };
    restartIfChanged = false;
    stopIfChanged = false;
  };

  # shutdown.target does not run for hibernate; systemd-sleep hooks cover the
  # pre-hibernate drain and the post-resume uncordon instead.
  environment.etc."systemd/system-sleep/k3s-node" =
    lib.mkIf (role == "server" && serverAddr == null)
      {
        source = pkgs.writeShellScript "k3s-node-sleep" ''
          set -u

          node=${lib.escapeShellArg config.networking.hostName}
          kubeconfig=/etc/rancher/k3s/k3s.yaml
          kubectl=${pkgs.kubectl}/bin/kubectl

          case "$1:$2" in
            pre:hibernate|pre:hybrid-sleep|pre:suspend-then-hibernate)
              "$kubectl" --kubeconfig "$kubeconfig" cordon "$node" --request-timeout=10s || true
              "$kubectl" --kubeconfig "$kubeconfig" drain "$node" \
                --ignore-daemonsets \
                --delete-emptydir-data \
                --timeout=60s || true
              ;;
            post:hibernate|post:hybrid-sleep|post:suspend-then-hibernate)
              for attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
                if "$kubectl" --kubeconfig "$kubeconfig" get node "$node" --request-timeout=3s >/dev/null 2>&1 \
                  && "$kubectl" --kubeconfig "$kubeconfig" uncordon "$node" --request-timeout=10s; then
                  exit 0
                fi
                ${pkgs.coreutils}/bin/sleep 5
              done
              exit 1
              ;;
          esac
        '';
        mode = "0755";
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
              - "http://rpi5:5000"
              - "https://registry-1.docker.io"
          rancher:
            endpoint:
              - "http://rpi5:5000"
              - "https://rancher.mirror.aliyuncs.com"
      '';
    };
  };
}
