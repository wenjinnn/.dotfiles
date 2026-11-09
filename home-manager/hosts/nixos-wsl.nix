{
  config,
  outputs,
  me,
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
    connectedHosts = [
      {
        label = "nixos";
        endpoint = "tcp://nixos.ts.${me.domain}:6767";
        passwordFile = config.sops.secrets.PASEO_PASSWORD.path;
      }
      {
        label = "rpi5";
        endpoint = "tcp://rpi5.ts.${me.domain}:6767";
        passwordFile = config.sops.secrets.PASEO_PASSWORD.path;
      }
    ];
  };

  sops.secrets.PASEO_PASSWORD = { };
  sops.templates."paseo.env".content = ''
    PASEO_PASSWORD=${config.sops.placeholder.PASEO_PASSWORD}
  '';
  systemd.user.services.paseo.Service.EnvironmentFile = config.sops.templates."paseo.env".path;
}
