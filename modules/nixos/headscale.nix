{
  config,
  me,
  domain,
  ...
}: {
  services = {
    headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;

      settings = {
        server_url = "https://hs.${domain}";
        logtail = {
          enabled = false;
        };
        ip_prefixes = [
          "100.77.0.0/24"
          "fd7a:115c:a1e0:77::/64"
        ];
        derp = {
          server = {
            enabled = true;
            region_id = 999;
            region_code = "headscale";
            region_name = "Headscale Embedded DERP";
            stun_listen_addr = "0.0.0.0:3478";
            auto_update_enabled = true;
            automatically_add_embedded_derp_region = true;
          };
        };

        metrics_listen_addr = "127.0.0.1:8090";
        dns =
          let
            base_domain = "ts.${domain}";
          in
          {
            override_local_dns = true;
            base_domain = base_domain;
            magic_dns = true;
            extra_records = [
              {
                name = "nextcloud.${base_domain}";
                type = "A";
                value = "100.64.0.1";
              }
              {
                name = "homeassistant.${base_domain}";
                type = "A";
                value = "100.64.0.1";
              }
              {
                name = "atuin.${base_domain}";
                type = "A";
                value = "100.64.0.1";
              }
              {
                name = "ariang.${base_domain}";
                type = "A";
                value = "100.64.0.1";
              }
              {
                name = "amule.${base_domain}";
                type = "A";
                value = "100.64.0.1";
              }
              {
                name = "matrix.${base_domain}";
                type = "A";
                value = "100.64.0.1";
              }
            ];
            nameservers.global = [
              "1.1.1.1"
              "1.0.0.1"
              "2606:4700:4700::1111"
              "2606:4700:4700::1001"
            ];
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
        "hs.${domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString config.services.headscale.port}";
              proxyWebsockets = true;
            };
            "/metrics" = {
              proxyPass = "http://${config.services.headscale.settings.metrics_listen_addr}/metrics";
            };
          };
        };
      };
    };
  };
  networking.firewall.allowedUDPPorts = [3478 41641];
  networking.firewall.allowedTCPPorts = [80 443];

  security.acme = {
    defaults.email = me.mail.outlook;
    acceptTerms = true;
  };
  environment.systemPackages = [
    config.services.headscale.package
  ];
}
