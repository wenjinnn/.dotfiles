{
  config,
  inputs,
  lib,
  me,
  ...
}:
{
  imports = [ inputs.paseo.nixosModules.default ];

  services.paseo = {
    enable = lib.mkDefault true;
    user = me.username;
    listenAddress = "0.0.0.0";
    relay.enable = false;
    settings.features.webUi.enabled = true;
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ config.services.paseo.port ];
}
