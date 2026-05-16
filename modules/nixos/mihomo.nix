{
  pkgs,
  config,
  outputs,
  ...
}: {
  imports = with outputs.nixosModules; [
    sops
  ];
  services.mihomo = {
    enable = true;
    configFile = config.sops.templates."mihomo.yaml".path;
    webui = pkgs.metacubexd;
    tunMode = true;
  };

  sops.templates."mihomo.yaml".content = ''
    proxy-providers:
      p1:
        type: http
        interval: 36000
        health-check:
          enable: true
          url: https://cp.cloudflare.com
          interval: 300
          timeout: 1000
          tolerance: 100
        path: ./proxy_provider/p1.yaml
        url: "${config.sops.placeholder.MIHOMO_PROVIDER}"
      p2:
        type: http
        interval: 36000
        health-check:
          enable: true
          url: https://cp.cloudflare.com
          interval: 300
          timeout: 1000
          tolerance: 100
        path: ./proxy_provider/p2.yaml
        url: "${config.sops.placeholder.MIHOMO_PROVIDER2}"
      p3:
        type: http
        interval: 36000
        health-check:
          enable: true
          url: https://cp.cloudflare.com
          interval: 300
          timeout: 1000
          tolerance: 100
        path: ./proxy_provider/p3.yaml
        url: "${config.sops.placeholder.MIHOMO_PROVIDER3}"
        # override:
        #   udp: true

      # local-subscription:
        # path: ./proxy_provider/local.yaml

    rule-providers:
      # anti-AD, can remove if had mistake
      # https://github.com/privacy-protection-tools/anti-AD
      anti-AD:
        type: http
        behavior: domain
        format: yaml
        path: ./rule_provider/anti-AD.yaml
        url: "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-clash.yaml?"
        interval: 6000
      anti-AD-white:
        type: http
        behavior: domain
        format: yaml
        path: ./rule_provider/anti-AD-white.yaml
        url: "https://raw.githubusercontent.com/privacy-protection-tools/dead-horse/master/anti-ad-white-for-clash.yaml?"
        interval: 6000

    mode: rule
    ipv6: true
    log-level: info
    allow-lan: true
    mixed-port: 7890
    # Meta feature https://wiki.metacubex.one/config/general
    unified-delay: true
    tcp-concurrent: true

    external-controller: :9090

    geodata-mode: true
    geo-auto-update: true
    geo-update-interval: 168

    geox-url:
      geoip: "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"
      geosite: "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
      mmdb: "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb"

    # default: strict
    find-process-mode: strict

    # set it to bigger number to reduce the power consumption issue on mobile devices
    # https://github.com/vernesong/OpenClash/issues/2614
    keep-alive-interval: 1800

    # 全局客户端指纹
    global-client-fingerprint: random # 随机指纹

    # 缓存
    profile:
      store-selected: true
      store-fake-ip: true

    # 自动同步时间以防止时间不准导致无法正常联网
    # ntp:
    #   enable: true
    #   # 是否同步至系统时间，需要 root/管理员权限
    #   write-to-system: false
    #   server: time.apple.com
    #   port: 123
    #   interval: 30

    # 域名嗅探
    sniffer:
      enable: true
      sniff:
        TLS:
          ports: [443, 8443]
        HTTP:
          ports: [80, 8080-8880]
          override-destination: true

    # tun 模式
    tun:
      enable: true  # enable 'true'
      stack: mixed  # 'gvisor' 'system' 'mixed'
      dns-hijack:
        - "any:53"
        - "tcp://any:53"
      auto-route: true
      auto-redirect: true
      auto-detect-interface: true
      strict-route: true
      exclude-interface:
        - "cni0"
        - "flannel.1"
        - "veth*"
      route-exclude-address:
        - "100.64.0.0/10"
        - "fd7a:115c:a1e0::/48"
        - "10.42.0.0/16"
        - "10.43.0.0/16"

    # dns 设置
    # 已配置 ipv6
    dns:
      enable: true
      ipv6: true
      listen: 0.0.0.0:1053
      respect-rules: true
      enhanced-mode: fake-ip
      fake-ip-filter:
        - "*"
        - "+.lan"
        - "+.local"
        - "+.market.xiaomi.com"
        - "+.wenjin.me"
      nameserver:
        - https://doh.pub/dns-query
        - https://dns.alidns.com/dns-query
      fallback:
        - 'tls://8.8.4.4#dns'
        - 'tls://1.0.0.1#dns'
        - 'tls://[2001:4860:4860::8844]#dns'
        - 'tls://[2606:4700:4700::1001]#dns'
      proxy-server-nameserver:
        - https://doh.pub/dns-query
      nameserver-policy:
        "+.cluster.local": "10.43.0.10"
        "+.in-addr.arpa": "10.43.0.10"
        "geosite:cn,private":
          - https://doh.pub/dns-query
          - https://dns.alidns.com/dns-query
        "geosite:geolocation-!cn":
          - "https://dns.cloudflare.com/dns-query"
          - "https://dns.google/dns-query"

    # 多入站端口设置
    # listeners:
    #   - name: hk
    #     type: mixed
    #     port: 12991
    #     proxy: hongkong

    #   - name: tw
    #     type: mixed
    #     port: 12992
    #     proxy: taiwan

    #   - name: sg
    #     type: mixed
    #     port: 12993
    #     proxy: singapore

    proxies:
      # - name: "WARP"
      #   type: wireguard
      #   server: engage.cloudflareclient.com
      #   port: 2408
      #   ip: "172.16.0.2/32"
      #   ipv6: "2606::1/128"        # 自行替换
      #   private-key: "private-key" # 自行替换
      #   public-key: "public-key"   # 自行替换
      #   udp: true
      #   reserved: "abba"           # 自行替换
      #   mtu: 1280
      #   dialer-proxy: "WARP前置"
      #   remote-dns-resolve: true
      #   dns:
      #     - https://dns.cloudflare.com/dns-query

    proxy-groups:
      # 使用 WARP 的用户需要手动在下方的 proxies 字段内添加 WARP
      # 例如 [WARP, all, auto-fast, hongkong, taiwan, japan, singapore, USA, other-region, DIRECT],
      - name: auto-fast
        type: url-test
        use:
        - p3
        - p2
        - p1
        tolerance: 2
      - name: JMS
        type: url-test
        use:
        - p3
      - name: manual
        type: select
        proxies:
        - all
        - auto-fast
        - hongkong
        - taiwan
        - japan
        - singapore
        - USA
        - other-region
        - DIRECT
      - name: dns
        type: select
        proxies:
        - auto-fast
        - manual
        - hongkong
        - taiwan
        - japan
        - singapore
        - USA
        - other-region
        - all
        - DIRECT
      # WARP 配置链式出站
      # - name: WARP前置
        # type: select
        # proxies:
        # - auto-fast
        # - select
        # - hongkong
        # - taiwan
        # - japan
        # - singapore
        # - USA
        # - other-region
        # - all
        # - DIRECT
        # exclude-type: "wireguard"

      - name: ad-block
        type: select
        proxies:
        - REJECT
        - DIRECT
        - manual

      - name: AI
        type: url-test
        proxies:
        - JMS
        - taiwan
        - singapore
        - japan
        - USA
        - france
        - germany
        - korea
        - canada
        - germany
        - ireland
        - SA
        - netherlands
        use:
        - p1
        filter: "S1|S2"
      - name: steam
        type: url-test
        use:
        - p1
        filter: "D1"
      - name: netflix
        type: url-test
        proxies:
        - taiwan
        - singapore
        - japan
        - USA
        use:
        - p2
      - name: video
        type: url-test
        proxies:
        - hongkong
        - netflix
        - taiwan
        - singapore
        - japan
        - USA
        use:
        - p1
        filter: "US|TW|SG|JA|HK|D1"
      - name: universal
        type: select
        proxies:
        - auto-fast
        - manual
        - hongkong
        - taiwan
        - japan
        - singapore
        - USA
        - other-region
        - all
        - DIRECT
      - name: local
        type: select
        proxies:
        - DIRECT
        - manual
        - hongkong
        - taiwan
        - japan
        - singapore
        - USA
        - korea
        - canada
        - germany
        - russia
        - ireland
        - SA
        - netherlands
        - france
        - other-region
        - all
        - auto-fast

      # continent
      - name: asia
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)亚|asia"

      # region
      - name: hongkong
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)港|hk|hongkong|hong kong"
      - name: taiwan
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)台|tw|taiwan"
      - name: japan
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)japan|jp|japan"
      - name: USA
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)美|unitedstates|united states"
      - name: UK
        type: url-test
        use:
        - p1
        filter: "(?i)英|uk|unitedkingdom|united kingdom"
      - name: korea
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)韩|korea"
      - name: canada
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)加|canada"
      - name: germany
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)德|ge|germany"
      - name: russia
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)俄|russia"
      - name: ireland
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)爱|ireland"
      - name: SA
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)非|sa|south africa"
      - name: netherlands
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)荷|cl|netherlands"
      - name: france
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)法|france"
      - name: singapore
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)(新|sg|singapore)"
      - name: other-region
        type: url-test
        use:
        - p2
        - p1
        filter: "(?i)^(?!.*(?:🇭🇰|🇯🇵|🇺🇸|🇸🇬|🇨🇳|港|hk|hongkong|台|tw|taiwan|日|jp|japan|新|sg|singapore|美|us|unitedstates|英|uk|unitedkingdom)).*"
      - name: all
        type: url-test
        use:
        - p2
        - p1


    rules:
      - PROCESS-NAME-REGEX,.*amule.*,DIRECT
      - PROCESS-NAME-REGEX,.*aria2c.*,DIRECT
      # - PROCESS-NAME-REGEX,.*tailscale*,DIRECT
      - GEOSITE,private,DIRECT,no-resolve
      - GEOIP,private,DIRECT,no-resolve
      - IP-CIDR,172.1.1.0/24,DIRECT,no-resolve
      - DOMAIN-SUFFIX,wenjin.me,DIRECT
      # 若需禁用 QUIC 请取消注释 QUIC 两条规则
      # 防止 YouTube 等使用 QUIC 导致速度不佳, 禁用 443 端口 UDP 流量（不包括国内）
      - AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOSITE,cn))),REJECT # quic
      - AND,((RULE-SET,anti-AD),(NOT,((RULE-SET,anti-AD-white)))),ad-block # 感谢 Telegram @nextyahooquery 提供的建议
    # - GEOSITE,biliintl,video
    # - GEOSITE,bilibili,video
      - GEOSITE,category-ads-all,REJECT

      - GEOSITE,category-ai-!cn,AI
      - GEOSITE,category-ai-chat-!cn,AI
      - GEOSITE,reddit,hongkong
      - GEOSITE,apple,universal
      - GEOSITE,apple-cn,universal
      - GEOSITE,ehentai,universal
      - GEOSITE,github,universal
      - GEOSITE,twitter,universal
      - GEOSITE,youtube,universal
      - GEOSITE,google,universal
      - GEOSITE,google-cn,universal # Google CN 不走代理会导致hongkong等地区节点 Play Store 异常
      - GEOSITE,telegram,universal
      - GEOSITE,netflix,netflix
      - GEOSITE,bahamut,universal
      - GEOSITE,spotify,universal
      - GEOSITE,pixiv,universal
      - GEOSITE,steam@cn,DIRECT
      - GEOSITE,steam,steam
      - GEOSITE,onedrive,universal
      - GEOSITE,microsoft,universal
      - GEOSITE,geolocation-!cn,universal
    # - AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOIP,CN))),REJECT # quic
      - GEOIP,google,universal
      - GEOIP,netflix,netflix
      - GEOIP,telegram,universal
      - GEOIP,twitter,universal
      - GEOSITE,CN,local
      - GEOIP,CN,local
      - MATCH,universal
  '';
}
