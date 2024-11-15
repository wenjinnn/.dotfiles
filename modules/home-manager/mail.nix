{
  pkgs,
  config,
  username,
  outlook,
  gmail,
  ...
}: let
  # for the follow script will be used in systemd unit, so we don't use ${sops_secrets} here
  sops_secrets = "${config.home.homeDirectory}/project/my/config/secrets.yaml";
  mutt_oauth2 = "${pkgs.neomutt}/share/neomutt/oauth2/mutt_oauth2.py";
  # outlook token setup
  outlook_oauth2_token_path = "${config.home.homeDirectory}/.cache/neomutt/${outlook}.tokens";
  init_outlook_oauth2_token = pkgs.writeShellScript "init_outlook_oauth2_token" ''
    export GPG_TTY=$(tty)
    ${mutt_oauth2} ${outlook_oauth2_token_path} \
    --verbose \
    --authorize \
    --provider microsoft \
    # should have a gpg key named 'wenjin for mail'
    --encryption-pipe "gpg --encrypt --recipient 'wenjin for mail'" \
    --client-id $(sops exec-env ${sops_secrets} 'echo -e $OUTLOOK_CLIENT_ID') \
    --client-secret "" \
    --authflow localhostauthcode \
    --email ${outlook}
  '';
  outlook_oauth2_token = pkgs.writeShellScript "outlook_oauth2_token" ''
    export GPG_TTY=$(tty)
    ${mutt_oauth2} ${outlook_oauth2_token_path}
  '';
  # gmail token setup
  gmail_oauth2_token_path = "${config.home.homeDirectory}/.cache/neomutt/${gmail}.tokens";
  init_gmail_oauth2_token = pkgs.writeShellScript "init_gmail_oauth2_token" ''
    export GPG_TTY=$(tty)
    ${mutt_oauth2} ${gmail_oauth2_token_path} \
    --verbose \
    --authorize \
    --provider google \
    # should have a gpg key named 'wenjin for mail'
    --encryption-pipe "gpg --encrypt --recipient 'wenjin for mail'" \
    --client-id $(sops exec-env ${sops_secrets} 'echo -e $GMAIL_CLIENT_ID') \
    --client-secret "$(sops exec-env ${sops_secrets} 'echo -e $GMAIL_CLIENT_SECRET')" \
    --authflow localhostauthcode \
    --email ${gmail}
  '';
  gmail_oauth2_token = pkgs.writeShellScript "gmail_oauth2_token" ''
    export GPG_TTY=$(tty)
    ${mutt_oauth2} ${gmail_oauth2_token_path}
  '';
  notmuch_new = "${pkgs.notmuch}/bin/notmuch new";
in {
  home.file = {
    ".local/bin/init_gmail_oauth2_token".source = init_gmail_oauth2_token;
    ".local/bin/init_outlook_oauth2_token".source = init_outlook_oauth2_token;
  };

  accounts.email.accounts = {
    ${outlook} = {
      realName = "${username}";
      userName = "${outlook}";
      address = "${outlook}";
      primary = true;
      maildir.path = "${outlook}";
      neomutt = {
        enable = true;
        mailboxName = "${outlook}";
      };
      notmuch.enable = true;
      passwordCommand = "${outlook_oauth2_token}";
      imapnotify = {
        enable = true;
        boxes = ["Inbox"];
        onNotifyPost = ''${pkgs.libnotify}/bin/notify-send "New Mail in:" "${outlook}"'';
        onNotify = "${pkgs.offlineimap}/bin/offlineimap -a ${outlook} && ${notmuch_new}";
        extraConfig = {
          xoAuth2 = true;
        };
      };
      imap = {
        host = "outlook.office365.com";
        tls.enable = true;
        port = 993;
      };
      smtp = {
        host = "smtp-mail.outlook.com";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };
      offlineimap = {
        enable = true;
        postSyncHookCommand = notmuch_new;
        extraConfig = {
          remote = {
            remotepasseval = false;
            auth_mechanisms = "XOAUTH2";
            oauth2_request_url = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
            oauth2_client_id_eval = ''get_output("sops exec-env ${sops_secrets} 'echo -e $OUTLOOK_CLIENT_ID'")'';
            oauth2_client_secret = "";
            oauth2_access_token_eval = ''get_output("${outlook_oauth2_token}")'';
          };
        };
      };
      msmtp = {
        enable = true;
        extraConfig = {
          auth = "xoauth2";
          passwordeval = "${outlook_oauth2_token}";
        };
      };
    };
    ${gmail} = {
      realName = "${username}";
      userName = "${gmail}";
      address = "${gmail}";
      maildir.path = "${gmail}";
      neomutt = {
        enable = true;
        mailboxName = "${gmail}";
      };
      notmuch.enable = true;
      passwordCommand = "${gmail_oauth2_token}";
      imapnotify = {
        enable = true;
        boxes = ["Inbox"];
        onNotifyPost = ''${pkgs.libnotify}/bin/notify-send "New Mail in:" "${gmail}"'';
        onNotify = "${pkgs.offlineimap}/bin/offlineimap -a ${gmail} && ${notmuch_new}";
        extraConfig = {
          xoAuth2 = true;
        };
      };
      imap = {
        host = "imap.gmail.com";
        tls.enable = true;
        port = 993;
      };
      smtp = {
        host = "smtp.gmail.com";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };
      offlineimap = {
        enable = true;
        postSyncHookCommand = notmuch_new;
        extraConfig = {
          local = {
            type = "GmailMaildir";
            nametrans = ''
              lambda foldername: re.sub ('Inbox', 'INBOX', foldername)
            '';
          };
          remote = {
            type = "Gmail";
            remotepasseval = false;
            auth_mechanisms = "XOAUTH2";
            oauth2_request_url = "https://oauth2.googleapis.com/token";
            oauth2_client_id_eval = ''get_output("sops exec-env ${sops_secrets} 'echo -e $GMAIL_CLIENT_ID'")'';
            oauth2_client_secret_eval = ''get_output("sops exec-env ${sops_secrets} 'echo -e $GMAIL_CLIENT_SECRET'")'';
            oauth2_access_token_eval = ''get_output("${gmail_oauth2_token}")'';
            nametrans = ''
              lambda foldername: re.sub ('INBOX', 'Inbox', foldername)
            '';
            folderfilter = ''lambda foldername: foldername not in ['[Gmail]/All Mail']'';
          };
        };
      };
      msmtp = {
        enable = true;
        extraConfig = {
          auth = "xoauth2";
          passwordeval = "${gmail_oauth2_token}";
        };
      };
    };
    # local mail box for read rss source
    ${username} = {
      realName = "${username}";
      userName = "${username}";
      address = "${username}@nixos.com";
      maildir.path = "${username}";
      neomutt = {
        enable = true;
        mailboxName = "${username}";
      };
      notmuch.enable = true;
      passwordCommand = "";
      imap = {
        host = "localhost";
      };
      smtp = {
        host = "localhost";
      };
    };
  };

  programs = {
    neomutt = {
      enable = true;
      vimKeys = true;
      extraConfig = ''
        unauto_view "*"
      '';
    };
    notmuch.enable = true;
    msmtp.enable = true;
    offlineimap = {
      enable = true;
      pythonFile = ''
        import subprocess

        def get_output(cmd):
            return subprocess.check_output(cmd, shell=True).decode('utf8')
      '';
    };
  };

  services.imapnotify.enable = true;

  home.file = {
    ".mailcap".text = ''
      audio/*; xdg-open %s

      image/*; xdg-open %s

      application/msword; xdg-open %s
      application/pdf; xdg-open %s
      application/postscript ; xdg-open %s

      application/x-gunzip; xdg-open %s
      application/x-tar-gz; xdg-open %s

      text/html; xdg-open %s ; nametemplate=%s.html
    '';
  };

}
