{ config, ... }:
{
  services.git-sync = {
    enable = true;
    repositories = {
      note = {
        path = config.home.sessionVariables.NOTE;
        uri = "git@github.com:wenjinnn/.note.git";
      };
    };
  };
}
