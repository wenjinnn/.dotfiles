{config, ...}: {
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = ["tun*" "Meta" "tailscale*"];
    allowedUDPPorts = [
      config.services.tailscale.port
      # snycthing
      22000
      21027
      # tailscale direct connection
      3478
      41641
      8000
      8472 # k3s, flannel: required if using multi-node for inter-node networking
    ];

    allowedTCPPorts = [
      80
      443
      4001
      8000
      8080
      # syncthing
      8384
      22000
      5001 # k3s: Embedded Registry Mirror
      6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
      2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
      2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
    ];
    allowedUDPPortRanges = [
      {
        from = 4000;
        to = 4007;
      }
      {
        from = 8000;
        to = 9000;
      }
    ];
  };
}
