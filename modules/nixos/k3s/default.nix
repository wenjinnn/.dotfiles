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

  services.k3s =
    let
      initMachine = serverAddr == null && role == "server";
    in
    {
      enable = true;
      inherit role;
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

    }
    // lib.optionalAttrs (serverAddr != null) { inherit serverAddr; };

  systemd.services.k3s = lib.mkMerge [
    (lib.mkIf config.services.tailscale.enable {
      after = [ "tailscaled.service" ];
      bindsTo = [ "tailscaled.service" ];
    })
  ];


}
