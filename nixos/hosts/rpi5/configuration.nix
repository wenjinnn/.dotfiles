# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  me,
  ...
}:
{
  # You can import other NixOS modules here
  imports = with outputs.nixosModules; [
    # If you want to use modules your own flake exports (from modules/nixos):

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    mihomo
    sops
    firewall
    tailscale
    podman
    ../../users.nix
    ./disko-usb-btrfs.nix
    ./pi5-configtxt.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];
  nixpkgs = {
    # You can add overlays here
    overlays = [
      (final: prev: {
        redis = prev.redis.overrideAttrs (old: {
          doCheck = false;
        });
      })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };
  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    amule
    amule-web
    amule-daemon
  ];
  sops.secrets.MATRIX_REGISTRATION_TOKEN = { };
  sops.secrets.MATRIX_REGISTRATION_TOKEN.owner = config.services.matrix-tuwunel.user;
  sops.secrets.MATRIX_REGISTRATION_TOKEN.group = config.services.matrix-tuwunel.group;
  services = {
    nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "samba.ts.wenjin.me" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:445";
            proxyWebsockets = true;
          };
        };
        "qbittorrent.ts.wenjin.me" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:8080";
            proxyWebsockets = true;
          };
        };
        "matrix.ts.wenjin.me" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:6167";
            proxyWebsockets = true;
          };
        };
        "homeassistant.ts.wenjin.me" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:8123";
            proxyWebsockets = true;
          };
        };
        "amule.ts.wenjin.me" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:4711";
            proxyWebsockets = true;
          };
        };
        "ariang.ts.wenjin.me" = {
          locations."/" = {
            root = "${pkgs.ariang}/share/ariang";
            index = "index.html";
          };
          locations."/jsonrpc" = {
            proxyPass = "http://127.0.0.1:6800/jsonrpc";
            proxyWebsockets = true;
          };
        };
        "atuin.ts.wenjin.me" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:8888";
          };
        };
      };
    };
    nextcloud = {
      enable = true;
      hostName = "nextcloud.ts.wenjin.me";
      database.createLocally = true;
      config = {
        dbtype = "pgsql";
        adminpassFile = config.sops.secrets.NEXTCLOUD_ADMIN_PASS.path;
      };
    };
    matrix-tuwunel = {
      enable = true;
      settings = {
        global = {
          server_name = "matrix.ts.wenjin.me";
          allow_registration = true;
          registration_token_file = config.sops.secrets.MATRIX_REGISTRATION_TOKEN.path;
        };
      };
    };
    home-assistant = {
      enable = true;
      openFirewall = true;
      customComponents = with pkgs.home-assistant-custom-components; [
        xiaomi_home
        xiaomi_gateway3
        xiaomi_miot
      ];
      extraPackages =
        python3Packages: with python3Packages; [
          gtts
        ];
      config = {
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
          ];
        };
        homeassistant = {
          name = "Home";
        };
      };
    };
    atuin = {
      enable = true;
      openFirewall = true;
      openRegistration = true;
      maxHistoryLength = 100000;
    };
    tailscale = {
      authKeyFile = config.sops.secrets.RPI5_TAILSCALE_AUTHKEY.path;
      useRoutingFeatures = "client";
      extraSetFlags = [ "--advertise-exit-node" ];
    };
    syncthing = {
      enable = true;
    };
    amule = {
      user = me.username;
      enable = true;
      dataDir = "/mnt/data/video/amule";
    };
    aria2 = {
      enable = true;
      openPorts = true;
      serviceUMask = "0000";
      rpcSecretFile = config.sops.secrets.RPI5_ARIA2_SECRET.path;
      downloadDirPermission = "2777";
      settings = {
        config-path = "/mnt/data/video/aria2/aria2.conf";
        save-session = "/mnt/data/video/aria2/aria2.session";
        bt-tracker = "udp://tracker.opentrackr.org:1337/announce,http://tracker.opentrackr.org:1337/announce,udp://open.demonii.com:1337/announce,udp://open.stealth.si:80/announce,udp://exodus.desync.com:6969/announce,udp://wepzone.net:6969/announce,udp://tracker.wepzone.net:6969/announce,udp://tracker.torrent.eu.org:451/announce,udp://tracker.theoks.net:6969/announce,udp://tracker.srv00.com:6969/announce,udp://tracker.qu.ax:6969/announce,udp://tracker.filemail.com:6969/announce,udp://tracker.corpscorp.online:80/announce,udp://tracker.bittor.pw:1337/announce,udp://tracker.alaskantf.com:6969/announce,udp://tracker-udp.gbitt.info:80/announce,udp://t.overflow.biz:6969/announce,udp://opentracker.io:6969/announce,udp://open.dstud.io:6969/announce,udp://explodie.org:6969/announce,udp://bittorrent-tracker.e-n-c-r-y-p-t.net:1337/announce,https://tracker.zhuqiy.com:443/announce,https://tracker.pmman.tech:443/announce,https://tracker.moeblog.cn:443/announce,https://tracker.bt4g.com:443/announce,https://torrent.tracker.durukanbal.com:443/announce,https://cny.fan:443/announce,http://www.torrentsnipe.info:2701/announce,http://wepzone.net:6969/announce,http://tracker.zhuqiy.com:80/announce,http://tracker.wepzone.net:6969/announce,http://tracker.tritan.gg:8080/announce,http://tracker.sbsub.com:2710/announce,http://tracker.renfei.net:8080/announce,http://tracker.qu.ax:6969/announce,http://tracker.mywaifu.best:6969/announce,http://tracker.lintk.me:2710/announce,http://tracker.ipv6tracker.org:80/announce,http://tracker.dmcomic.org:2710/announce,http://tracker.dler.org:6969/announce,http://tracker.dler.com:6969/announce,http://tracker.dhitechnical.com:6969/announce,http://tracker.corpscorp.online:80/announce,http://tracker.bz:80/announce,http://tracker.bt4g.com:2095/announce,http://tracker.bt-hash.com:80/announce,http://tracker.bittor.pw:1337/announce,http://tracker.alaskantf.com:6969/announce,http://tr.kxmp.cf:80/announce,http://t.overflow.biz:6969/announce,http://servandroidkino.ru:80/announce,http://retracker.spark-rostov.ru:80/announce,http://open.trackerlist.xyz:80/announce,http://open.acgtracker.com:1096/announce,http://extracker.dahrkael.net:6969/announce,http://bvarf.tracker.sh:2086/announce,http://bittorrent-tracker.e-n-c-r-y-p-t.net:1337/announce,http://0d.kebhana.mx:443/announce,udp://utracker.ghostchu-services.top:6969/announce,udp://udp.tracker.projectk.org:23333/announce,udp://tracker.zupix.online:6969/announce,udp://tracker.tvunderground.org.ru:3218/announce,udp://tracker.tryhackx.org:6969/announce,udp://tracker.torrust-demo.com:6969/announce,udp://tracker.therarbg.to:6969/announce,udp://tracker.t-1.org:6969/announce,udp://tracker.startwork.cv:1337/announce,udp://tracker.plx.im:6969/announce,udp://tracker.playground.ru:6969/announce,udp://tracker.opentorrent.top:6969/announce,udp://tracker.ixuexi.click:6969/announce,udp://tracker.gmi.gd:6969/announce,udp://tracker.fnix.net:6969/announce,udp://tracker.flatuslifir.is:6969/announce,udp://tracker.ducks.party:1984/announce,udp://tracker.dler.org:6969/announce,udp://tracker.ddunlimited.net:6969/announce,udp://tracker.cloudbase.store:1333/announce,udp://tracker.bluefrog.pw:2710/announce,udp://tracker.1h.is:1337/announce,udp://tr4ck3r.duckdns.org:6969/announce,udp://torrentclub.online:54123/announce,udp://retracker.lanta.me:2710/announce,udp://rekcart.duckdns.org:15480/announce,udp://ns575949.ip-51-222-82.net:6969/announce,udp://martin-gebhardt.eu:25/announce,udp://leet-tracker.moe:1337/announce,udp://ipv4announce.sktorrent.eu:6969/announce,udp://evan.im:6969/announce,udp://d40969.acod.regrucolo.ru:6969/announce,udp://bandito.byterunner.io:6969/announce,https://tracker.iochimari.moe:443/announce,https://tracker.ghostchu-services.top:443/announce,https://tracker.gcrenwp.top:443/announce,https://tr.nyacat.pw:443/announce,https://t.213891.xyz:443/announce,https://shahidrazi.online:443/announce,http://tracker2.dler.org:80/announce,http://tracker.waaa.moe:6969/announce,http://tracker.tvunderground.org.ru:3218/announce,http://tracker.ghostchu-services.top:80/announce,http://tr.nyacat.pw:80/announce,http://tr.highstar.shop:80/announce,http://shubt.net:2710/announce,http://lucke.fenesisu.moe:6969/announce,http://buny.uk:6969/announce,http://aboutbeautifulgallopinghorsesinthegreenpasture.online:80/announce,http://1337.abcvg.info:80/announce";
        dir = "/mnt/data/video/aria2";
        enable-rpc = true;
        rpc-listen-all = true;
        rpc-allow-origin-all = true;
      };
    };
    qbittorrent = {
      enable = true;
      openFirewall = true;
      user = "wenjin";
      group = "users";
    };
    samba = {
      enable = true;
      openFirewall = true;
      nmbd.extraArgs = [ "--option=interfaces= lo wlan0 end0" ];
      settings = {
        global = {
          "invalid users" = [
            "root"
          ];
          # "passwd program" = "/run/wrappers/bin/passwd %u";
          security = "user";
        };
        public = {
          browseable = "yes";
          comment = "Public samba share.";
          "read only" = "no";
          "write list" = "root, @sambashare, aria2, @aria2";
          path = "/mnt/data";
          # "admin users" = "@sambashare";
        };
      };
      # shares = {
      #   nas = {
      #     path = "/mnt/nas/public";
      #     writeable = true;
      #     browseable = true;
      #     createMode = "0777";
      #     directoryMode = "0777";
      #     forceUser = "root";
      #     forceGroup = "root";
      #   };
      # };
    };
  };
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/3b4a7972-8635-40ad-8f8f-488187b7d75a";
    fsType = "btrfs";
    options = [
      "noatime"
      "nofail"
      "compress=zstd"
      "x-systemd.automount"
      "x-systemd.idle-timeout=1min"
    ];
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        # flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
        trusted-users = [ "${me.username}" ];
        # the system-level substituers & trusted-public-keys
        # given the users in this list the right to specify additional substituters via:
        #    1. `nixConfig.substituers` in `flake.nix`
        substituters = [
          # cache mirror located in China
          # status: https://mirror.sjtu.edu.cn/
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          # status: https://mirrors.ustc.edu.cn/status/
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
        trusted-public-keys = [
          # the default public key of cache.nixos.org, it's built-in, no need to add it here
          # "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ];
      };
      # do garbage collection weekly to keep disk usage low
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    bash = {
      blesh.enable = true;
      vteIntegration = true;
    };
    nix-ld.enable = true;
  };

  users.users.root.initialHashedPassword = "";
  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberry-pi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];

  boot.tmp.useTmpfs = true;
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  # This is mostly portions of safe network configuration defaults that
  # nixos-images and srvos provide

  # networking.useNetworkd = true;
  # mdns
  networking.nat.enable = true;
  networking.nat.enableIPv6 = true;
  networking.firewall = {
    allowedUDPPorts = [
      5353
      1053
      53
      67
    ];
    allowedTCPPorts = [
      80
      5353
      1053
      53
      67
      4711 # aMuleWeb HTTP port
      4712 # aMule External Connections (EC) port
    ];
    trustedInterfaces = [ "wlan0" ];

    # extraCommands = "
    #   nft insert rule filter nixos-fw iifname wlan0  udp dport 67 accept
    #   nft insert rule filter nixos-fw iifname wlan0  udp dport 53 accept
    #   nft insert rule filter nixos-fw iifname wlan0  tcp dport 53 accept
    # ";
  };
  # networking.firewall.extraInputRules = ''
  #   iifname { "end0", "wlan0" } meta l4proto { tcp, udp } th dport 53 accept comment "DNS"
  #   iifname { "end0", "wlan0" } meta nfproto ipv4 udp dport 67 accept comment "DHCP server"
  # '';
  #
  systemd.network.networks = {
    "99-ethernet-default-dhcp".networkConfig.MulticastDNS = "yes";
    "99-wireless-client-dhcp".networkConfig.MulticastDNS = "yes";
  };
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "wlan0";
      dhcp-range = "192.168.222.2,192.168.222.254,24h";
      dhcp-option = [
        "option:router,192.168.222.1"
        "option:dns-server,192.168.222.1"
      ];
      no-resolv = true;
      cache-size = 1000;
      server = [ "127.0.0.1#1053" ];
    };
  };

  # This comment was lifted from `srvos`
  # Do not take down the network for too long when upgrading,
  # This also prevents failures of services that are restarted instead of stopped.
  # It will use `systemctl restart` rather than stopping it with `systemctl stop`
  # followed by a delayed `systemctl start`.
  systemd.services = {
    aria2.serviceConfig = {
      User = lib.mkForce me.username;
      Group = lib.mkForce "users";
    };
    # Configure the amuleweb systemd service
    amuleweb = {
      enable = true;
      description = "aMule Web Interface";
      after = [
        "network.target"
        "amuled.service"
      ]; # Ensure amule daemon is running
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "wenjin";
        Group = "users";
        ExecStart = "${pkgs.amule-web}/bin/amuleweb --amule-config-file=${config.services.amule.dataDir}/.aMule/amule.conf";
        Restart = "always";
        WorkingDirectory = "/mnt/data/video/amule/.aMule"; # Set working directory for amuleweb
      };
    };
    # systemd-networkd.stopIfChanged = false;
    # Services that are only restarted might be not able to resolve when resolved is stopped before
    # systemd-resolved.stopIfChanged = false;
  };
  networking.interfaces = {
    end0 = {
      useDHCP = true;
    };
    wlan0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.222.1";
          prefixLength = 24;
        }
      ];
    };
  };
  services.hostapd = {
    enable = true;
    radios = {
      # Simple 2.4GHz AP
      wlan0 = {
        countryCode = "CN";
        networks.wlan0 = {
          ssid = "rpi5nixos";
          authentication.saePasswords = [ { passwordFile = config.sops.secrets.RPI5_PASS.path; } ];
        };
      };

    };
  };

  # Use iwd instead of wpa_supplicant. It has a user friendly CLI
  networking.wireless.interfaces = [ "wlan0" ];
  # networking.wireless.enable = false;
  # networking.wireless.iwd = {
  #   enable = true;
  #   settings = {
  #     Network = {
  #       EnableIPv6 = true;
  #       RoutePriorityOffset = 300;
  #     };
  #     Settings.AutoConnect = true;
  #   };
  # };
  services.udev.extraRules = ''
    # ACTION=="add", SUBSYSTEM=="block", \
    # ENV{ID_FS_UUID}=="3b4a7972-8635-40ad-8f8f-488187b7d75a", \
    # RUN+="${pkgs.systemd}/bin/systemctl start mnt-nas.mount"
    # Ignore partitions with "Required Partition" GPT partition attribute
    # On our RPis this is firmware (/boot/firmware) partition
    ENV{ID_PART_ENTRY_SCHEME}=="gpt", \
      ENV{ID_PART_ENTRY_FLAGS}=="0x1", \
      ENV{UDISKS_IGNORE}="1"
  '';

  networking.hostName = "rpi${config.boot.loader.raspberry-pi.variant}";

  boot.loader.raspberry-pi.bootloader = "kernel";
}
