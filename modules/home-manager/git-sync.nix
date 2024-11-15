{config, ...}: {
  services.git-sync = {
    enable = true;
    repositories.archive = {
      path = "${config.home.homeDirectory}/.archive";
      uri = "git@github.com:wenjinnn/archive.git";
    };
  };
}
