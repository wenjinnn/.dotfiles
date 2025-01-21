{
  modulesPath,
  config,
  lib,
  pkgs,
  me,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services = {
    openssh.enable = true;
    rustdesk-server = {
      enable = true;
      relay.enable = true;
      signal.enable = true;
      openFirewall = true;
      signal.relayHosts = ["hs.wenjin.me"];
    };
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;

      settings = {
        server_url = "https://hs.wenjin.me";

        dns = {
          override_local_dns = true;
          base_domain = "ts.wenjin.me";
          metrics_listen_addr = "127.0.0.1:8090";
          magic_dns = true;
          nameservers.global = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
          ];
          logtail = {
            enabled = false;
          };
          ip_prefixes = [
            "100.77.0.0/24"
            "fd7a:115c:a1e0:77::/64"
          ];
          derp.server = {
            enabled = true;
            region_id = 999;
            stun_listen_addr = "0.0.0.0:3478";
          };
        };
      };
    };
    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      virtualHosts = {
        "hs.wenjin.me" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
            "/metrics" = {
              proxyPass = "http://${config.services.headscale.settings.dns.metrics_listen_addr}/metrics";
            };
          };
        };
      };
    };
  };
  networking.firewall.allowedUDPPorts = [3478];
  networking.firewall.allowedTCPPorts = [80 443];

  security.acme = {
    defaults.email = me.mail.outlook;
    acceptTerms = true;
  };
  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    config.services.headscale.package
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpMRzF5l2trX2SwRxYn4KcSahIKVbU+T+Li+IE5qMIw wenjin@nixos-wsl"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtBUbTuGD34mJCUZp7hIFuDR9kACg4y8iWhjAPB5R66 wenjin@nixos"
  ];

  system.stateVersion = "24.05";
}
