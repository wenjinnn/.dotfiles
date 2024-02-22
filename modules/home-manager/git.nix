{
  username,
  ...
}: {
  # git
  programs.git = {
    enable = true;
    userName = "${username}";
    userEmail = "hewenjin94@outlook.com";
    extraConfig = {
      color.ui = true;
      credential.helper = "store";
      github.user = "wenjinnn";
      push.autoSetupRemote = true;
      mergetool.keepBackup = false;
      merge.tool = "nvimdiff";
      diff.tool = "nvimdiff";
    };
  };
}
