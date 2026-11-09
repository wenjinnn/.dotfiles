{
  me,
  ...
}:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraUpFlags = [ "--login-server=https://hs.${me.domain}" ];
  };
}
