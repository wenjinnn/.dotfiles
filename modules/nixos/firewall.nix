{
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = ["tun*" "Meta"];
    allowedTCPPorts = [80 443 4001];
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
