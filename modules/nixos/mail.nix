{
  config,
  pkgs,
  me,
  ...
}:
{
  systemd.tmpfiles.rules =
    let
      accountMaildir = "/home/${me.username}/Maildir/${me.username}";
      maildir = "${accountMaildir}/Inbox";
    in
    [
      "d ${accountMaildir} 0700 ${me.username} users - -"
      "z ${accountMaildir} 0700 ${me.username} users - -"
      "d ${maildir} 0700 ${me.username} users - -"
      "d ${maildir}/cur 0700 ${me.username} users - -"
      "d ${maildir}/new 0700 ${me.username} users - -"
      "d ${maildir}/tmp 0700 ${me.username} users - -"
      "z ${maildir} 0700 ${me.username} users - -"
      "z ${maildir}/cur 0700 ${me.username} users - -"
      "z ${maildir}/new 0700 ${me.username} users - -"
      "z ${maildir}/tmp 0700 ${me.username} users - -"
    ];

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
      enablePAM = true;
      settings = {
        dovecot_config_version = config.services.dovecot2.package.version;
        dovecot_storage_version = config.services.dovecot2.package.version;
        mail_driver = "maildir";
        mail_path = "~/Maildir/%{user}/Inbox";
        protocols = {
          lmtp = true;
        };
      };
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
