{
  config,
  outputs,
  ...
}:
{
  imports = with outputs.homeManagerModules; [ paseo ];

  services.paseo = {
    enable = true;
    listenAddress = "0.0.0.0";
    hostnames = true;
    relay.enable = false;
    settings.features.webUi.enabled = true;
  };

  sops.secrets.PASEO_PASSWORD = { };
  sops.templates."paseo.env".content = ''
    PASEO_PASSWORD=${config.sops.placeholder.PASEO_PASSWORD}
  '';
  systemd.user.services.paseo.Service.EnvironmentFile = config.sops.templates."paseo.env".path;
}
