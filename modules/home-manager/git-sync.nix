{
  config,
  ...
}: {
  services.git-sync = {
    enable = true;
    repositories.archive = {
      path = "${config.home.homeDirectory}/project/my/archive";
      uri = "git@github.com:wenjinnn/archive.git";
    };
  };
}

