{
  me,
  pkgs,
  ...
}: {
  # git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user = {
        name = me.username;
        email = me.mail.outlook;
      };
      color.ui = true;
      credential.helper = "store";
      github.user = "wenjinnn";
      push.autoSetupRemote = true;
      mergetool.keepBackup = false;
      mergetool.nvimdiff.layout = "LOCAL,BASE,REMOTE / MERGED + BASE,LOCAL + BASE,REMOTE";
      merge.tool = "nvimdiff";
      diff.tool = "nvimdiff";
      core.autocrlf = "input";
    };
  };
}
