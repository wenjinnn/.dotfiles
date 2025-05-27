{
  pkgs,
  me,
  ...
}: {
  services = {
    offlineimap = {
      enable = true;
      install = true;
      onCalendar = "*:0/30";
      path = with pkgs; [
        bash
        notmuch
        gnupg
        sops
      ];
    };
    # setup lmtp and rss2email for read local rss source
    dovecot2 = {
      enable = true;
      enableLmtp = true;
      mailLocation = "maildir:~/Maildir/%u/Inbox";
    };
    rss2email = {
      enable = true;
      to = me.username;
      interval = "1h";
      config = {
        sendmail = "/run/wrappers/bin/sendmail";
        email-protocol = "lmtp";
        lmtp-server = "/var/run/dovecot2/lmtp";
        lmtp-auth = "False";
      };
      feeds = {
        hyprland.url = "https://hyprland.org/rss.xml";
        neovim.url = "https://neovim.io/news.xml";
        vaxry-blog.url = "https://blog.vaxry.net/feed";
      };
    };
  };
}
