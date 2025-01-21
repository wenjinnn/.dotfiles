{
  me,
  pkgs,
  ...
}: {
  # git
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = me.username;
    userEmail = me.mail.outlook;
    extraConfig = {
      color.ui = true;
      credential.helper = "store";
      github.user = "wenjinnn";
      push.autoSetupRemote = true;
      mergetool.keepBackup = false;
      merge.tool = "vimdiff";
      diff.tool = "vimdiff";
      core.autocrlf = "input";
    };
  };
}
