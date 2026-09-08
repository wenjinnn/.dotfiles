{
  me,
  ...
}:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--login-server=https://hs.wenjin.me" ];
    # dnsmasq/openresolv owns /etc/resolv.conf; Tailscale DNS conflicts with it.
    extraSetFlags = [ "--accept-dns=false" ];
  };
}
