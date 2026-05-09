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
      traefik-config.text = ''
        apiVersion: helm.cattle.io/v1
        kind: HelmChartConfig
        metadata:
          name: traefik
          namespace: kube-system
        spec:
          valuesContent: |-
            # 这里是 Traefik 的自定义配置
            additionalArguments:
              # 添加证书解析器，用于自动申请 Let's Encrypt 证书
              - "--certificatesresolvers.default.acme.email=hewenjin94@outlook.com"  # 替换为你的邮箱
              - "--certificatesresolvers.default.acme.storage=/data/acme.json"
              - "--certificatesresolvers.default.acme.httpchallenge.entrypoint=web"  # 使用 HTTP-01 验证
            ports:
              web:
                exposedPort: 8000
              websecure:
                exposedPort: 8443

      '';
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
