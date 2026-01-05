{
  pkgs,
  config,
  ...
}: {
  programs.aria2 = {
    enable = true;
    # TODO get bt-tracker from https://github.com/ngosang/trackerslist, maybe write a script later.
    extraConfig = ''
      bt-tracker=udp://tracker.opentrackr.org:1337/announce,udp://open.demonoid.ch:6969/announce,udp://open.demonii.com:1337/announce,udp://open.stealth.si:80/announce,udp://tracker.torrent.eu.org:451/announce,udp://explodie.org:6969/announce,udp://tracker1.myporn.club:9337/announce,udp://tracker.theoks.net:6969/announce,udp://tracker.qu.ax:6969/announce,udp://tracker.filemail.com:6969/announce,udp://tracker.dler.org:6969/announce,udp://tracker.bittor.pw:1337/announce,udp://tracker.0x7c0.com:6969/announce,udp://tracker-udp.gbitt.info:80/announce,udp://run.publictracker.xyz:6969/announce,udp://retracker01-msk-virt.corbina.net:80/announce,udp://p4p.arenabg.com:1337/announce,udp://opentracker.io:6969/announce,udp://open.tracker.cl:1337/announce,udp://leet-tracker.moe:1337/announce,
    '';
    settings = {
      listen-port = 4001;
      dht-listen-port = 4000;
      dir = "${config.home.homeDirectory}/Downloads/aria2";
      enable-rpc = true;
      rpc-listen-all = true;
      rpc-allow-origin-all = true;
    };
  };
  home.packages = with pkgs; [
    # accessiable through ~/.nix-profile/share/ariang/index.html
    ariang
  ];
}
