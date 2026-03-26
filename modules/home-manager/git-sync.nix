{ config, ... }:
{
  services.git-sync = {
    enable = true;
    repositories = {
      note = {
        path = config.home.sessionVariables.NOTE;
        uri = "git@github.com:wenjinnn/.note.git";
      };
      pass = {
        path = "${config.home.homeDirectory}/.password-store";
        uri = "git@github.com:wenjinnn/.password-store.git";
      };
    };
  };
}
