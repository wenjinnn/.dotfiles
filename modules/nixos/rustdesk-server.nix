{
  me,
  ...
}:
{
  services = {
    rustdesk-server = {
      enable = true;
      relay.enable = true;
      signal.enable = true;
      openFirewall = true;
      signal.relayHosts = [ me.domain ];
    };
  };
}
