{ ... }:
{
  home.username = "wenjin";
  home.homeDirectory = "/home/wenjin";
  home.stateVersion = "26.05";

  imports = [ ../../modules/home-manager/paseo.nix ];

  services.paseo = {
    enable = true;
    listenAddress = "0.0.0.0";
    relay.enable = false;
    settings.features.webUi.enabled = true;
  };
}
