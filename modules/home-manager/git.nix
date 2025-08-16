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
      mergetool.nvimdiff.layout = "LOCAL,BASE,REMOTE / MERGED + BASE,LOCAL + BASE,REMOTE + (LOCAL/BASE/REMOTE),MERGED";
      merge.tool = "nvimdiff";
      diff.tool = "nvimdiff";
      core.autocrlf = "input";
    };
  };
}
