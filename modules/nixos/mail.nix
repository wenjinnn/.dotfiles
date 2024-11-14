{
  pkgs,
  outlook,
  username,
  config,
  ...
}: {
  programs.msmtp = {
    enable = true;
    setSendmail = true;
  };
  services = {
    offlineimap = {
      enable = true;
      install = true;
      path = with pkgs; [
        bash
        notmuch
        gnupg
        sops
      ];
    };
    rss2email = {
      enable = true;
      to = outlook;
      config = {
        from = outlook;
        sendmail = "/run/wrappers/bin/sendmail";
      };
      feeds = {
        hacknews.url = "https://rsshub.app/hackernews";
      };
    };
  };
}
