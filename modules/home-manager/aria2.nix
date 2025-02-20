{
  pkgs,
  config,
  ...
}: {
  programs.aria2 = {
    enable = true;
    # TODO get bt-tracker from https://github.com/ngosang/trackerslist, maybe write a script later.
    extraConfig = ''
      bt-tracker=udp://93.158.213.92:1337/announce,udp://23.134.89.9:1337/announce,udp://186.10.181.37:1337/announce,udp://185.243.218.213:80/announce,udp://208.83.20.20:6969/announce,udp://15.204.56.171:6969/announce,udp://45.9.60.30:6969/announce,udp://104.244.77.87:6969/announce,udp://23.153.248.83:6969/announce,udp://83.102.180.21:80/announce,udp://37.235.176.37:2710/announce,udp://34.89.51.235:6969/announce,udp://5.181.156.41:6969/announce,udp://198.12.89.149:6969/announce,udp://37.27.4.53:6969/announce,udp://185.216.179.62:25/announce
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
