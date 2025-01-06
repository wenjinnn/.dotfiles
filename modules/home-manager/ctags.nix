{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    universal-ctags
  ];
  xdg.configFile = {
    "ctags/my.ctags".text = ''
      --recurse=yes
      --exclude=.git
      --exclude=BUILD
      --exclude=.svn
      --exclude=*vendor/*
      --exclude=*node_modules/*
      --exclude=*target/*
      --exclude=*log/*
      --exclude=\*.min.\*
      --exclude=\*.swp
      --exclude=\*.bak
      --exclude=\*.pyc
      --exclude=\*.class
      --exclude=\*.sln
      --exclude=\*.csproj
      --exclude=\*.csproj.user
      --exclude=\*.cache
      --exclude=\*.dll
      --exclude=\*.pdb
    '';
  };
}
