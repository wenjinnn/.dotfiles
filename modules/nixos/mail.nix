{
  pkgs,
  outlook,
  username,
  config,
  ...
}: {
  programs.msmtp = let
    mutt_oauth2 = "${pkgs.neomutt}/share/neomutt/oauth2/mutt_oauth2.py";
    outlook_oauth2_token_path = "/var/rss2email/${outlook}.tokens";
  in {
    enable = true;
    setSendmail = true;
    accounts = {
      ${outlook} = {
        auth = "xoauth2";
        host = "smtp-mail.outlook.com";
        from = "${outlook}";
        port = 587;
        tls = true;
        tls_starttls = true;
        user = "${outlook}";
        # need to exec init_outlook_oauth2_token first, see ../home-manager/mail.nix
        passwordeval = "\"GPG_TTY=$(tty) ${mutt_oauth2} ${outlook_oauth2_token_path}\"";
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
      };
    };
  };
  services = {
    offlineimap = {
      enable = true;
      install = true;
      onCalendar = "*:0/10";
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
      feeds = {
        hacknews.url = "https://rsshub.app/hackernews";
      };
    };
  };
}
