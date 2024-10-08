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
    package = pkgs.unstable.mihomo;
    configFile = config.sops.templates."mihomo.yaml".path;
    webui = pkgs.unstable.metacubexd;
    tunMode = true;
  };

  sops.templates."mihomo.yaml".content = ''
    # mihomo (Clash Meta) 懒人配置
    # 版本 V1.8-240904
    # https://gist.github.com/liuran001/5ca84f7def53c70b554d3f765ff86a33
    # https://obdo.cc/meta
    # 作者: 笨蛋ovo (bdovo.cc)
    # Telegram: https://t.me/baka_not_baka
    # 关注我的 Telegram 频道谢谢喵 https://t.me/s/BDovo_Channel
    # 修改自官方示例规则 https://wiki.metacubex.one/example/#meta
    # 转载请保留此注释
    # 尽量添加了较为详尽的注释，不理解的地方建议对照 虚空终端 (Clash Meta) Docs 进行理解
    # 虚空终端 (Clash Meta) Docs 地址: https://wiki.metacubex.one
    # 不理解的地方不要乱动，如果你是小白，请按下 `Ctrl + F` 搜索 `基础配置`，只修改此部分

    # true 是启用
    # false 是禁用

    # 分组
    pr:
      &pr {
        type: select,
        proxies:
          [
            自动选择,
            节点选择,
            香港,
            台湾,
            日本,
            新加坡,
            美国,
            其它地区,
            全部节点,
            DIRECT,
          ],
      }
    # 延迟检测 URL
    p: &p
      type: http
      # 自动更新订阅时间，单位为秒
      interval: 3600
      health-check:
        enable: true
        url: https://cp.cloudflare.com
        # 节点连通性检测时间，单位为秒
        interval: 300
        # 节点超时延迟，单位为毫秒
        timeout: 1000
        # 节点自动切换差值，单位为毫秒
        tolerance: 100

    # 基础配置
    # --------------------------------------------------
    # 如果你是小白，那么你只需要修改分割线以内的内容
    # 其他部分保持不动即可
    # 如果你需要使用大于两个机场，在下方 `use` 处添加 `订阅三` （名字可以自己取），然后在 `proxy-providers` 照例添加订阅链接即可
    # 反之，如果你只需要使用一个，那么将 `订阅二` 前添加 `#` 进行注释即可

    # 订阅名，记得修改成自己的
    # 添删订阅在这里和下方订阅链接依葫芦画瓢就行
    use: &use
      # 如果不希望自动切换请将下面两行注释对调
      # type: select
      type: url-test
      use:
        - p1
        # - 订阅二
        # - 本地配置

    # 订阅链接
    # 对于订阅来说，path 为选填项，但建议启用
    # 本地配置可以只填 path
    proxy-providers:
      p1:
        <<: *p
        path: ./proxy_provider/p1.yaml
        url: "${config.sops.placeholder.MIHOMO_PROVIDER}"

      # 订阅二:
      #   <<: *p
      #   # path: ./proxy_provider/订阅二.yaml
      #   url: "https://example.com/api/v1/client/subscribe?token=ilovechina"

      # 本地配置:
        # <<: *p
        # path: ./proxy_provider/本地配置.yaml

    # 小白请不要继续随意修改以下设置
    # 若需修改请参阅文档 https://wiki.metacubex.one
    # --------------------------------------------------

    # 规则订阅
    rule-providers:
      # anti-AD 广告拦截规则
      # https://github.com/privacy-protection-tools/anti-AD
      # 如果误杀率高请自行更换
      anti-AD:
        type: http
        behavior: domain
        format: yaml
        # path可为空(仅限clash.meta 1.15.0以上版本)
        path: ./rule_provider/anti-AD.yaml
        url: "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-clash.yaml?"
        interval: 600
      # anti-AD 白名单规则
      anti-AD-white:
        type: http
        behavior: domain
        format: yaml
        # path可为空(仅限clash.meta 1.15.0以上版本)
        path: ./rule_provider/anti-AD-white.yaml
        url: "https://raw.githubusercontent.com/privacy-protection-tools/dead-horse/master/anti-ad-white-for-clash.yaml?"
        interval: 600
      # custom
      r1:
        type: http
        behavior: domain
        format: yaml
        # path可为空(仅限clash.meta 1.15.0以上版本)
        path: ./rule_provider/r1.yaml
        url: "${config.sops.placeholder.MIHOMO_PROVIDER}"
        interval: 600

    mode: rule
    # ipv6 支持
    ipv6: true
    log-level: info
    # 允许局域网连接
    allow-lan: true
    # socks5/http 端口
    mixed-port: 7890
    # Meta 内核特性 https://wiki.metacubex.one/config/general
    # 统一延迟
    # 更换延迟计算方式,去除握手等额外延迟
    unified-delay: true
    # TCP 并发
    # 同时对所有ip进行连接，返回延迟最低的地址
    tcp-concurrent: true
    # 外部控制端口
    external-controller: :9090

    geodata-mode: true

    # Geo 数据库下载地址
    # 使用 FastGit 代理 (https://fgit.cf)
    # 源地址 https://github.com/MetaCubeX/meta-rules-dat
    # 可以更换镜像站但不要更换其他数据库，可能导致无法启动
    geox-url:
      geoip: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat"
      geosite: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
      mmdb: "https://hub.gitmirror.com/https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/country.mmdb"

    # 进程匹配模式
    # 路由器上请设置为 off
    # always 开启，强制匹配所有进程
    # strict 默认，由 Clash 判断是否开启
    # off 不匹配进程，推荐在路由器上使用此模式
    find-process-mode: strict

    # 缓解移动设备耗电问题
    # https://github.com/vernesong/OpenClash/issues/2614
    keep-alive-interval: 1800

    # 全局客户端指纹
    global-client-fingerprint: random # 随机指纹

    # 缓存
    profile:
      store-selected: true
      store-fake-ip: true

    # 自动同步时间以防止时间不准导致无法正常联网
    ntp:
      enable: true
      # 是否同步至系统时间，需要 root/管理员权限
      write-to-system: false
      server: time.apple.com
      port: 123
      interval: 30

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
      stack: system  # or 'gvisor'
      dns-hijack:
        - "any:53"
        - "tcp://any:53"
      auto-route: true
      auto-detect-interface: true

    # dns 设置
    # 已配置 ipv6
    dns:
      enable: true
      listen: :1053
      ipv6: true
      # 路由器个人建议使用 redir-host 以最佳兼容性
      # 其他设备可以使用 fake-ip
      enhanced-mode: fake-ip
      fake-ip-range: 28.0.0.1/8
      fake-ip-filter:
        - '*'
        - '+.lan'
        - '+.local'
      default-nameserver:
        - 223.5.5.5
        - 119.29.29.29
        - 114.114.114.114
        - '[2402:4e00::]'
        - '[2400:3200::1]'
      nameserver:
        - 'tls://8.8.4.4#dns'
        - 'tls://1.0.0.1#dns'
        - 'tls://[2001:4860:4860::8844]#dns'
        - 'tls://[2606:4700:4700::1001]#dns'
      proxy-server-nameserver:
        - https://doh.pub/dns-query
      nameserver-policy:
        "geosite:cn,private":
          - https://doh.pub/dns-query
          - https://dns.alidns.com/dns-query

    # 多入站端口设置
    # listeners:
    #   - name: hk
    #     type: mixed
    #     port: 12991
    #     proxy: 香港

    #   - name: tw
    #     type: mixed
    #     port: 12992
    #     proxy: 台湾

    #   - name: sg
    #     type: mixed
    #     port: 12993
    #     proxy: 新加坡

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
      # 例如 [WARP, 全部节点, 自动选择, 香港, 台湾, 日本, 新加坡, 美国, 其它地区, DIRECT],
      - { name: 自动选择, <<: *use, tolerance: 2, type: url-test }
      - {
          name: 节点选择,
          type: select,
          proxies:
            [全部节点, 自动选择, 香港, 台湾, 日本, 新加坡, 美国, 其它地区, DIRECT],
        }
      # 这里的 dns 指海外解析 dns 走的节点，一般跟随节点选择即可
      - { name: dns, <<: *pr }
      # WARP 配置链式出站
      # - { name: WARP前置, <<: *pr, exclude-type: "wireguard" }

      - { name: 广告拦截, type: select, proxies: [REJECT, DIRECT, 节点选择] }
      - { name: OpenAI, <<: *pr }
      # Apple 推荐走全局直连
      - { name: Apple, <<: *pr }
      - { name: Google, <<: *pr }
      - { name: Telegram, <<: *pr }
      - { name: Twitter, <<: *pr }
      - { name: Pixiv, <<: *pr }
      - { name: ehentai, <<: *pr }
      # 下面两个看需求启用，打开之后会代理全站流量，可能导致部分版权视频反而无法播放或视频播放速度缓慢
      # 下面 rules 两条也要启用
    # - {name: 哔哩哔哩, <<: *pr}
    # - {name: 哔哩东南亚, <<: *pr}
      - { name: 巴哈姆特, <<: *pr }
      - { name: YouTube, <<: *pr }
      - { name: NETFLIX, <<: *pr }
      - { name: Spotify, <<: *pr }
      - { name: Github, <<: *pr }
      - { name: Steam, <<: *pr }
      - { name: OneDrive, <<: *pr }
      - { name: 微软服务, <<: *pr }
      - {
          name: 订阅,
          type: select,
          use:
            [
              p1,
            ],
        }
      - {
          name: 国内,
          type: select,
          proxies:
            [
              DIRECT,
              节点选择,
              香港,
              台湾,
              日本,
              新加坡,
              美国,
              其它地区,
              全部节点,
              自动选择,
            ],
        }
      # 其他就是所有规则没匹配到的
      # 可以理解为 ACL4SSR 配置里的 漏网之鱼
      # 换言之，其他走代理就是绕过中国大陆地址，不走就是 GFWList 模式
      - {
          name: 局域网,
          type: select,
          filter: "192.168.*|172.16.*|172.1.*|10.0.*",
          proxies: [ DIRECT ]
        }
      - { name: 其他, <<: *pr }

      # 分隔,下面是地区分组
      - { name: 香港, <<: *use, filter: "(?i)港|hk|hongkong|hong kong" }
      - { name: 台湾, <<: *use, filter: "(?i)台|tw|taiwan" }
      - { name: 日本, <<: *use, filter: "(?i)日本|jp|japan" }
      - { name: 美国, <<: *use, filter: "(?i)美|us|unitedstates|united states" }
      - { name: 新加坡, <<: *use, filter: "(?i)(新|sg|singapore)" }
      - {
          name: 其它地区,
          <<: *use,
          filter: "(?i)^(?!.*(?:🇭🇰|🇯🇵|🇺🇸|🇸🇬|🇨🇳|港|hk|hongkong|台|tw|taiwan|日|jp|japan|新|sg|singapore|美|us|unitedstates)).*",
        }
      - { name: 全部节点, <<: *use }

    rules:
      # 若需禁用 QUIC 请取消注释 QUIC 两条规则
      # 防止 YouTube 等使用 QUIC 导致速度不佳, 禁用 443 端口 UDP 流量（不包括国内）

    # - AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOSITE,cn))),REJECT # quic
      - AND,((RULE-SET,anti-AD),(NOT,((RULE-SET,anti-AD-white)))),广告拦截 # 感谢 Telegram @nextyahooquery 提供的建议
    # - GEOSITE,biliintl,哔哩东南亚
    # - GEOSITE,bilibili,哔哩哔哩

      - GEOSITE,openai,OpenAI
      - GEOSITE,apple,Apple
      - GEOSITE,apple-cn,Apple
      - GEOSITE,ehentai,ehentai
      - GEOSITE,github,Github
      - GEOSITE,twitter,Twitter
      - GEOSITE,youtube,YouTube
      - GEOSITE,google,Google
      - GEOSITE,google-cn,Google # Google CN 不走代理会导致香港等地区节点 Play Store 异常
      - GEOSITE,telegram,Telegram
      - GEOSITE,netflix,NETFLIX
      - GEOSITE,bahamut,巴哈姆特
      - GEOSITE,spotify,Spotify
      - GEOSITE,pixiv,Pixiv
      - GEOSITE,steam@cn,DIRECT
      - GEOSITE,steam,Steam
      - GEOSITE,onedrive,OneDrive
      - GEOSITE,microsoft,微软服务
      - GEOSITE,geolocation-!cn,其他
    # - AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOIP,CN))),REJECT # quic
      - GEOIP,google,Google
      - GEOIP,netflix,NETFLIX
      - GEOIP,telegram,Telegram
      - GEOIP,twitter,Twitter
      - GEOSITE,CN,国内
      - GEOIP,CN,国内
      - RULE-SET,r1,订阅
      - MATCH,局域网
      - MATCH,其他
  '';
}
