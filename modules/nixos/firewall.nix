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
    ];

    allowedTCPPorts = [
      80
      443
      4001
      8080
      # syncthing
      8384
      22000
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
