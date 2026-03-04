{ config, ... }:
{
  services.git-sync = {
    enable = true;
    repositories = {
      archive = {
        path = config.home.sessionVariables.ARCHIVE;
        uri = "git@github.com:wenjinnn/.archive.git";
      };
      note = {
        path = config.home.sessionVariables.NOTE;
        uri = "git@github.com:wenjinnn/.note.git";
      };
    };
  };
}
